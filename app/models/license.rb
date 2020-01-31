# frozen_string_literal: true

class License < ApplicationRecord
  include Sluggable
  include Limitable
  include Tokenable
  include Pageable
  include Roleable
  include Searchable

  EXCLUDED_KEYS = %w[actions action].freeze

  SEARCH_ATTRIBUTES = %i[id key name metadata].freeze
  SEARCH_RELATIONSHIPS = {
    product: %i[id name],
    policy: %i[id name],
    user: %i[id email]
  }

  search attributes: SEARCH_ATTRIBUTES, relationships: SEARCH_RELATIONSHIPS

  sluggable attributes: %i[id key]

  belongs_to :account
  belongs_to :user
  belongs_to :policy
  has_many :tokens, as: :bearer, dependent: :destroy
  has_many :machines, dependent: :destroy
  has_one :product, through: :policy
  has_one :role, as: :resource, dependent: :destroy

  # Used for legacy encrypted licenses
  attr_reader :raw

  before_validation :encrypt_key, on: :create, unless: -> { key.nil? || policy.nil? || !scheme? || legacy_encrypted? }
  before_create -> { self.protected = policy.protected? }, if: -> { policy.present? && protected.nil? }
  before_create :set_first_check_in, if: -> { requires_check_in? }
  before_create :set_expiry, unless: -> { expiry.present? || policy.nil? }
  after_create :set_autogenerated_key, unless: -> { key.present? || policy.nil? }
  after_create :set_role

  validates :account, presence: { message: "must exist" }
  validates :policy, presence: { message: "must exist" }

   # Validate this association only if we've been given a user (because it's optional)
  validates :user, presence: { message: "must exist" }, unless: -> { user_id.nil? }

  validate on: :create, unless: -> { policy.nil? } do
    errors.add :key, :conflict, message: "must not conflict with another license's identifier (UUID)" if key.present? && key =~ UUID_REGEX && account.licenses.exists?(key)

    # This is for our original "encrypted" keys only (legacy scheme)
    errors.add :key, :not_supported, message: "cannot be specified for a legacy encrypted license" if key.present? && legacy_encrypted?

    # This is for our new key encryption schemes
    errors.add :key, :blank, message: "must be specified for a license using #{scheme}" if key.nil? && scheme? && !legacy_encrypted?
  end

  validate on: :update do |license|
    next if license&.uses.nil? || license.policy&.max_uses.nil?
    next if license.uses <= license.policy.max_uses

    license.errors.add :uses, :limit_exceeded, message: "usage exceeds maximum allowed by current policy (#{license.policy.max_uses})"
  end

  validates :key, uniqueness: { case_sensitive: true, scope: :account_id }, exclusion: { in: Sluggable::EXCLUDED_SLUGS, message: "is reserved" }, unless: -> { key.nil? }
  validates :metadata, length: { maximum: 64, message: "too many keys (exceeded limit of 64 keys)" }
  validates :uses, numericality: { greater_than_or_equal_to: 0 }

  scope :suspended, -> (status = true) { where suspended: ActiveRecord::Type::Boolean.new.cast(status) }
  scope :unassigned, -> (status = true) {
    if ActiveRecord::Type::Boolean.new.cast(status)
      where 'user_id IS NULL'
    else
      where 'user_id IS NOT NULL'
    end
  }
  scope :expired, -> (status = true) {
    if ActiveRecord::Type::Boolean.new.cast(status)
      where 'expiry IS NOT NULL AND expiry < ?', Time.current
    else
      where 'expiry IS NULL OR expiry >= ?', Time.current
    end
  }
  scope :metadata, -> (meta) { search_metadata meta }
  scope :policy, -> (id) { where policy: id }
  scope :user, -> (id) { where user: id }
  scope :product, -> (id) { joins(:policy).where policies: { product_id: id } }
  scope :machine, -> (id) { joins(:machines).where machines: { id: id } }
  scope :fingerprint, -> (fp) { joins(:machines).where machines: { fingerprint: fp } }

  delegate :requires_check_in?, to: :policy
  delegate :check_in_interval, to: :policy
  delegate :check_in_interval_count, to: :policy
  delegate :encrypted?, to: :policy
  delegate :legacy_encrypted?, to: :policy
  delegate :scheme?, to: :policy
  delegate :scheme, to: :policy
  delegate :pool?, to: :policy

  def protected?
    return policy.protected? if protected.nil?

    protected
  end

  def suspended?
    suspended
  end

  def expired?
    return false if expiry.nil?

    expiry < Time.current
  end

  def check_in_overdue?
    return false unless requires_check_in?

    last_check_in_at < check_in_interval_count.send(check_in_interval).ago
  rescue NoMethodError
    nil
  end

  def next_check_in_at
    return nil unless requires_check_in?

    last_check_in_at + check_in_interval_count.send(check_in_interval) rescue nil
  end

  def check_in!
    return false unless requires_check_in?

    self.last_check_in_at = Time.current
    save
  end

  def renew!
    return false if expiry.nil?

    self.expiry += ActiveSupport::Duration.build(policy.duration)
    save
  end

  def suspend!
    self.suspended = true
    save
  end

  def reinstate!
    self.suspended = false
    save
  end

  private

  def set_role
    grant! :license
  end

  def set_first_check_in
    return if last_check_in_at.present?

    self.last_check_in_at = Time.current
  end

  def set_expiry
    if policy.duration.nil?
      self.expiry = nil
    else
      self.expiry = Time.current + ActiveSupport::Duration.build(policy.duration)
    end
  end

  def set_autogenerated_key
    return if key.present? || (scheme? && !legacy_encrypted?)

    case
    when legacy_encrypted?
      generate_legacy_encrypted_key!
    when pool?
      generate_pooled_key!
    else
      generate_raw_key!
    end

    # We're raising a RecordInvalid exception so that the transaction will be
    # halted and rolled back (since our record is invalid without a key)
    raise ActiveRecord::RecordInvalid if key.nil?

    save
  end

  def encrypt_key
    return unless key.present?

    case scheme
    when "RSA_2048_PKCS1_ENCRYPT"
      generate_pkcs1_encrypted_key!
    when "RSA_2048_PKCS1_SIGN"
      generate_pkcs1_signed_key!
    when "RSA_2048_PKCS1_PSS_SIGN"
      generate_pkcs1_pss_signed_key!
    when "RSA_2048_JWT_RS256"
      generate_jwt_rs256_key!
    when "DSA_2048_SIGN"
      generate_dsa_signed_key!
    when "ECDSA_SECP256K1_SIGN"
      generate_ecdsa_secp256k1_signed_key!
    end

    raise ActiveRecord::RecordInvalid if key.nil?
  end

  def generate_pooled_key!
    if item = policy.pop!
      self.key = item.key
    else
      errors.add :policy, :pool_empty, message: "pool is empty"
    end
  end

  def generate_legacy_encrypted_key!
    @raw, enc = generate_hashed_token :key, version: "v1" do |token|
      # Replace first n characters with our id so that we can do a lookup
      # on the encrypted key
      token.gsub(/\A.{#{UUID_LENGTH}}/, id.delete("-"))
           .scan(/.{#{UUID_LENGTH}}/).join("-")
    end

    self.key = enc
  end

  def generate_raw_key!
    self.key = generate_token :key, length: 16 do |token|
      # Split every n characters, e.g. XXXX-XXXX-XXXX
      token.scan(/.{1,6}/).join("-").upcase
    end
  end

  def generate_pkcs1_encrypted_key!
    if key.bytesize <= RSA_MAX_BYTE_SIZE
      priv = OpenSSL::PKey::RSA.new account.rsa_private_key
      enc = priv.private_encrypt key

      self.key = Base64.urlsafe_encode64 enc
    else
      errors.add :key, :byte_size_exceeded, message: "key exceeds maximum byte length (max size of #{RSA_MAX_BYTE_SIZE} bytes)"
    end
  end

  def generate_pkcs1_signed_key!
    priv = OpenSSL::PKey::RSA.new account.rsa_private_key
    sig = priv.sign OpenSSL::Digest::SHA256.new, key

    encoded_key = Base64.urlsafe_encode64 key
    encoded_sig = Base64.urlsafe_encode64 sig

    self.key = "#{encoded_key}.#{encoded_sig}"
  end

  def generate_pkcs1_pss_signed_key!
    priv = OpenSSL::PKey::RSA.new account.rsa_private_key
    sig = priv.sign_pss OpenSSL::Digest::SHA256.new, key, salt_length: :max, mgf1_hash: "SHA256"

    encoded_key = Base64.urlsafe_encode64 key
    encoded_sig = Base64.urlsafe_encode64 sig

    self.key = "#{encoded_key}.#{encoded_sig}"
  end

  def generate_jwt_rs256_key!
    priv = OpenSSL::PKey::RSA.new account.rsa_private_key
    payload = JSON.parse key
    jwt = JWT.encode payload, priv, "RS256"

    self.key = jwt
  rescue JSON::GeneratorError,
         JSON::ParserError
    errors.add :key, :jwt_claims_invalid, message: "key is not a valid JWT claims payload (must be a valid JSON encoded string)"
  rescue JWT::InvalidPayload => e
    errors.add :key, :jwt_claims_invalid, message: "key is not a valid JWT claims payload (#{e.message})"
  end

  def generate_dsa_signed_key!
    priv = OpenSSL::PKey::DSA.new account.dsa_private_key

    sig = priv.sign OpenSSL::Digest::SHA256.new, key

    encoded_key = Base64.urlsafe_encode64 key
    encoded_sig = Base64.urlsafe_encode64 sig

    self.key = "#{encoded_key}.#{encoded_sig}"
  end

  def generate_ecdsa_secp256k1_signed_key!
    group = OpenSSL::PKey::EC::Group.new ECDSA_GROUP
    ec = OpenSSL::PKey::EC.new group
    bn = OpenSSL::BN.new account.ecdsa_private_key, 16
    ec.private_key = bn

    sig = ec.sign OpenSSL::Digest::SHA256.new, key

    encoded_key = Base64.urlsafe_encode64 key
    encoded_sig = Base64.urlsafe_encode64 sig

    self.key = "#{encoded_key}.#{encoded_sig}"
  end
end

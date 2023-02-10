# frozen_string_literal: true

class ReleaseUpgradeLink < ApplicationRecord
  include Environmental
  include Limitable
  include Orderable
  include Pageable

  belongs_to :account
  belongs_to :release,
    counter_cache: :upgrade_count,
    inverse_of: :upgrade_links

  has_environment default: -> { release&.environment_id }

  encrypts :url

  validates :release,
    scope: { by: :account_id }

  validates :url,
    presence: true
end

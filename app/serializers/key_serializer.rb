# frozen_string_literal: true

class KeySerializer < BaseSerializer
  type 'keys'

  attribute :key
  attribute :created do
    @object.created_at
  end
  attribute :updated do
    @object.updated_at
  end

  relationship :account do
    linkage always: true do
      { type: :accounts, id: @object.account_id }
    end
    link :related do
      @url_helpers.v1_account_path @object.account_id
    end
  end

  ee do
    relationship :environment do
      linkage always: true do
        if @object.environment_id.present?
          { type: :environments, id: @object.environment_id }
        else
          nil
        end
      end
      link :related do
        unless @object.environment_id.nil?
          @url_helpers.v1_account_environment_path @object.account_id, @object.environment_id
        end
      end
    end
  end

  relationship :product do
    linkage always: true do
      { type: :products, id: @object.product&.id }
    end
    link :related do
      @url_helpers.v1_account_key_product_path @object.account_id, @object
    end
  end

  relationship :policy do
    linkage always: true do
      { type: :policies, id: @object.policy_id }
    end
    link :related do
      @url_helpers.v1_account_key_policy_path @object.account_id, @object
    end
  end

  link :self do
    @url_helpers.v1_account_key_path @object.account_id, @object
  end
end

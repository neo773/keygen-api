# frozen_string_literal: true

class EntitlementSerializer < BaseSerializer
  type "entitlements"

  attribute :name
  attribute :code
  attribute :metadata do
    @object.metadata&.transform_keys { |k| k.to_s.camelize :lower } or {}
  end
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

  relationship :environment do
    linkage always: true do
      if @object.environment_id?
        { type: :environments, id: @object.environment_id }
      else
        nil
      end
    end
    link :related do
      @url_helpers.v1_account_entitlement_environment_path @object.account_id, @object
    end
  end

  link :self do
    @url_helpers.v1_account_entitlement_path @object.account_id, @object
  end
end

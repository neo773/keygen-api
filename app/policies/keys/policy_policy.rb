# frozen_string_literal: true

module Keys
  class PolicyPolicy < ApplicationPolicy
    authorize :key

    def show?
      verify_permissions!('policy.read')

      case bearer
      in role: { name: 'admin' | 'developer' | 'sales_agent' | 'support_agent' | 'read_only' }
        allow!
      in role: { name: 'product' } if key.product == bearer
        allow!
      else
        deny!
      end
    end
  end
end

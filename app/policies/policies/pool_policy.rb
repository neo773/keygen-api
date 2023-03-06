# frozen_string_literal: true

module Policies
  class PoolPolicy < ApplicationPolicy
    authorize :policy

    def index?
      verify_permissions!('key.read')
      verify_environment!(
        strict: false,
      )

      case bearer
      in role: { name: 'admin' | 'developer' | 'sales_agent' | 'support_agent' | 'read_only' }
        allow!
      in role: { name: 'product' } if policy.product == bearer
        record.all? { _1.product == bearer }
      else
        deny!
      end
    end

    def show?
      verify_permissions!('key.read')
      verify_environment!(
        strict: false,
      )

      case bearer
      in role: { name: 'admin' | 'developer' | 'sales_agent' | 'support_agent' | 'read_only' }
        allow!
      in role: { name: 'product' } if policy.product == bearer
        record.product == bearer
      else
        deny!
      end
    end

    def pop?
      verify_permissions!('policy.pool.pop')
      verify_environment!

      case bearer
      in role: { name: 'admin' | 'developer' }
        allow!
      in role: { name: 'product' } if policy.product == bearer
        allow!
      else
        deny!
      end
    end
  end
end

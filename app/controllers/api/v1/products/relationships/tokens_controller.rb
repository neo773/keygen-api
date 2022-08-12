# frozen_string_literal: true

module Api::V1::Products::Relationships
  class TokensController < Api::V1::BaseController
    before_action :scope_to_current_account!
    before_action :require_active_subscription!
    before_action :authenticate_with_token!
    before_action :set_product

    authorize :product

    def index
      tokens = apply_pagination(authorized_scope(apply_scopes(product.tokens)))
      authorize! tokens,
        with: Products::TokenPolicy

      render jsonapi: tokens
    end

    def show
      token = product.tokens.find(params[:id])
      authorize! token,
        with: Products::TokenPolicy

      render jsonapi: token
    end

    def create
      authorize! with: Products::TokenPolicy

      kwargs = token_params.to_h.symbolize_keys.slice(
        :permissions,
        :expiry,
      )

      token = TokenGeneratorService.call(
        account: current_account,
        bearer: product,
        **kwargs,
      )

      BroadcastEventService.call(
        event: 'token.generated',
        account: current_account,
        resource: token,
      )

      render jsonapi: token
    end

    private

    attr_reader :product

    def set_product
      scoped_products = authorized_scope(current_account.products)

      @product = scoped_products.find(params[:product_id])

      Current.resource = product
    end

    typed_parameters format: :jsonapi do
      options strict: true

      on :create do
        param :data, type: :hash, optional: true do
          param :type, type: :string, inclusion: %w[token tokens]
          param :attributes, type: :hash do
            param :expiry, type: :datetime, allow_nil: true, optional: true, coerce: true
            if current_bearer&.has_role?(:admin, :product)
              param :permissions, type: :array, optional: true do
                items type: :string
              end
            end
          end
        end
      end
    end
  end
end

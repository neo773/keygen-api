# frozen_string_literal: true

module Api::V1
  class RequestLogsController < Api::V1::BaseController
    has_scope :date, type: :hash, using: [:start, :end], only: :index
    has_scope(:requestor, type: :hash, using: [:type, :id]) { |_, s, (t, id)| s.search_requestor(t, id) }
    has_scope(:resource, type: :hash, using: [:type, :id]) { |_, s, (t, id)| s.search_resource(t, id) }
    has_scope(:request) { |c, s, v| s.search_request_id(v) }
    has_scope(:ip) { |c, s, v| s.search_ip(v) }
    has_scope(:method) { |c, s, v| s.search_method(v) }
    has_scope(:url) { |c, s, v| s.search_url(v) }
    has_scope(:status) { |c, s, v| s.search_status(v) }
    has_scope(:event) { |c, s, v| s.for_event_type(v) }

    before_action :scope_to_current_account!
    before_action :require_active_subscription!
    before_action :authenticate_with_token!
    before_action :set_request_log, only: [:show]

    # GET /request-logs
    def index
      authorize RequestLog

      json = Rails.cache.fetch(cache_key, expires_in: 1.minute, race_condition_ttl: 30.seconds) do
        request_logs = apply_pagination(policy_scope(apply_scopes(current_account.request_logs.strict_loading)))
        data = Keygen::JSONAPI::Renderer.new.render(request_logs)

        data.tap do |d|
          d[:links] = pagination_links(request_logs)
        end
      end

      render json: json
    end

    # GET /request-logs/1
    def show
      authorize @request_log

      render jsonapi: @request_log
    end

    private

    def set_request_log
      @request_log = current_account.request_logs.find params[:id]
    end

    def cache_key
      [:logs, current_account.id, Digest::SHA2.hexdigest(request.query_string), CACHE_KEY_VERSION].join ":"
    end
  end
end

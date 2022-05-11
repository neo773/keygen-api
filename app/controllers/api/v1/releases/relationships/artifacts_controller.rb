# frozen_string_literal: true

module Api::V1::Releases::Relationships
  class ArtifactsController < Api::V1::BaseController
    has_scope(:channel) { |c, s, v| s.for_channel(v) }
    has_scope(:status) { |c, s, v| s.with_status(v) }

    before_action :scope_to_current_account!
    before_action :require_active_subscription!
    before_action :authenticate_with_token!, except: %i[index show]
    before_action :authenticate_with_token, only: %i[index show]
    before_action :set_release, only: %i[index show]
    before_action :set_artifact, only: %i[show]

    def index
      artifacts = apply_pagination(apply_scopes(policy_scope(release.artifacts)).preload(:platform, :arch, :filetype))
      authorize artifacts

      render jsonapi: artifacts
    end

    def show
      authorize artifact

      if artifact.downloadable?
        download = artifact.download!(ttl: artifact_query[:ttl])

        BroadcastEventService.call(
          event: %w[artifact.downloaded release.downloaded],
          account: current_account,
          resource: artifact,
        )

        # Show we support `Prefer: no-redirect` for browser clients?
        render jsonapi: artifact, status: :see_other, location: download.url
      else
        render jsonapi: artifact
      end
    end

    private

    attr_reader :release,
                :artifact

    def set_release
      scoped_releases = policy_scope(current_account.releases)

      @release = FindByAliasService.call(
        scope: scoped_releases,
        identifier: params[:release_id],
        aliases: %i[version tag],
      )

      Current.resource = release
    end

    def set_artifact
      scoped_artifacts = apply_scopes(policy_scope(release.artifacts))

      @artifact = FindByAliasService.call(
        scope: scoped_artifacts.order_by_version,
        identifier: params[:id],
        aliases: :filename,
        reorder: false,
      )
    end

    typed_query do
      on :show do
        if current_bearer&.has_role?(:admin, :developer, :sales_agent, :support_agent, :product)
          query :ttl, type: :integer, coerce: true, optional: true
        end
      end
    end
  end
end

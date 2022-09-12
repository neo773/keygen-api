# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

describe Releases::ProductPolicy, type: :policy do
  subject { described_class.new(record, account:, bearer:, token:, release:) }

  with_role_authorization :admin do
    with_scenarios %i[accessing_a_release accessing_its_product] do
      with_token_authentication do
        with_permissions %w[release.product.read] do
          without_token_permissions { denies :show }

          allows :show
        end

        with_wildcard_permissions do
          without_token_permissions { denies :show }

          allows :show
        end

        with_default_permissions do
          without_token_permissions { denies :show }

          allows :show
        end

        without_permissions do
          denies :show
        end
      end
    end
  end

  with_role_authorization :product do
    with_scenarios %i[accessing_its_release accessing_its_product] do
      with_token_authentication do
        with_permissions %w[release.product.read] do
          without_token_permissions { denies :show }

          allows :show
        end

        with_wildcard_permissions do
          without_token_permissions { denies :show }

          allows :show
        end

        with_default_permissions do
          without_token_permissions { denies :show }

          allows :show
        end

        without_permissions do
          denies :show
        end
      end
    end

    with_scenarios %i[accessing_a_release accessing_its_product] do
      with_token_authentication do
        with_permissions %w[release.product.read] do
          denies :show
        end

        with_wildcard_permissions do
          denies :show
        end

        with_default_permissions do
          denies :show
        end

        without_permissions do
          denies :show
        end
      end
    end
  end

  with_role_authorization :license do
    with_scenarios %i[accessing_its_release accessing_its_product] do
      with_license_authentication do
        with_permissions %w[release.product.read] do
          allows :show
        end

        with_wildcard_permissions { allows :show }
        with_default_permissions  { denies :show }
        without_permissions       { denies :show }
      end

      with_token_authentication do
        with_permissions %w[release.product.read] do
          without_token_permissions { denies :show }

          allows :show
        end

        with_wildcard_permissions do
          without_token_permissions { denies :show }

          allows :show
        end

        with_default_permissions { denies :show }
        without_permissions      { denies :show }
      end
    end

    with_scenarios %i[accessing_a_release accessing_its_product] do
      with_license_authentication do
        with_wildcard_permissions { denies :show }
        with_default_permissions  { denies :show }
        without_permissions       { denies :show }
      end

      with_token_authentication do
        with_wildcard_permissions { denies :show }
        with_default_permissions  { denies :show }
        without_permissions       { denies :show }
      end
    end
  end

  with_role_authorization :user do
    with_bearer_trait :with_licenses do
      with_scenarios %i[accessing_its_release accessing_its_product] do
        with_token_authentication do
          with_permissions %w[release.product.read] do
            without_token_permissions { denies :show }

            allows :show
          end

          with_wildcard_permissions { allows :show }
          with_default_permissions  { denies :show }
          without_permissions       { denies :show }
        end
      end
    end

    with_scenarios %i[accessing_a_release accessing_its_product] do
      with_token_authentication do
        with_wildcard_permissions { denies :show }
        with_default_permissions  { denies :show }
        without_permissions       { denies :show }
      end
    end
  end

  without_authorization do
    with_scenarios %i[accessing_a_release accessing_its_product] do
      without_authentication { denies :show }
    end
  end
end

module Api::V1
  class PasswordsController < Api::V1::BaseController
    before_action :scope_to_current_account!
    before_action :set_user, only: [:reset_password]

    # POST /passwords
    def reset_password
      skip_authorization

      @user.send_password_reset_email if @user
    end

    private

    attr_reader :parameters

    def set_user
      @user = current_account.users.find_by_email parameters[:email]
    end

    def parameters
      @parameters ||= TypedParameters.build self do
        options strict: true

        on :reset_password do
          param :email, type: :string
        end
      end
    end
  end
end

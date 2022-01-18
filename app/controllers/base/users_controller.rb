# frozen_string_literal: true

module Base
  class UsersController < ApplicationController
    before_action :assign_email

    def confirm_new
      @result = Cognito::ConfirmSignUp.new
    end

    def confirm
      @result = Cognito::ConfirmSignUp.call(confirm_sign_up_params)
      if @result.success?
        Rails.logger.info 'ACCOUNT ACTIVATION SUCCESSFUL'
        redirect_to base_new_user_session_path
      else
        Rails.logger.info "ACCOUNT ACTIVATION FAILED: #{get_error_list(@result.errors)}"
        render :confirm_new
      end
    end

    def resend_confirmation_email
      result = Cognito::ResendConfirmationCode.call(@email)
      Rails.logger.info 'ACCOUNT ACTIVATION EMAIL RESENT'

      redirect_to base_users_confirm_path_path(e: params[:e]), error: result.error
    end

    private

    def confirm_sign_up_params
      params.require(:cognito_confirm_sign_up).permit(
        :confirmation_code,
        :email
      )
    end

    def assign_email
      @email = params[:e].present? ? TextEncryptor.decrypt(params[:e]) : confirm_sign_up_params[:email]
    end
  end
end

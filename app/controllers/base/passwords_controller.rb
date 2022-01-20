# frozen_string_literal: true

module Base
  class PasswordsController < ApplicationController
    def new
      @response = Cognito::ForgotPassword.new(nil)
    end

    def create
      @response = Cognito::ForgotPassword.call(forgot_password_params[:email])
      if @response.success?
        Rails.logger.info 'FORGOT PASSWORD EMAIL SENT'

        redirect_to base_edit_user_password_path(e: TextEncryptor.encrypt(forgot_password_params[:email]))
      else
        Rails.logger.info "FORGOT PASSWORD FAILED: #{get_error_list(@response.errors)}"

        render :new
      end
    end

    def edit
      @response = Cognito::ConfirmPasswordReset.new({ email: TextEncryptor.decrypt(params[:e]) })
    end

    def update
      @response = Cognito::ConfirmPasswordReset.call(confirm_password_params)

      if @response.success?
        Rails.logger.info 'PASSWORD RESET SUCCESS'

        redirect_to home_path
      else
        Rails.logger.info "PASSWORD RESET FAILED: #{get_error_list(@response.errors)}"

        render :edit, erorr: @response.error
      end
    end

    def password_reset_success; end

    def confirm_new; end

    private

    def forgot_password_params
      params.require(:cognito_forgot_password).permit(:email)
    end

    def confirm_password_params
      params.require(:cognito_confirm_password_reset).permit(
        :email,
        :password,
        :password_confirmation,
        :confirmation_code,
      )
    end
  end
end

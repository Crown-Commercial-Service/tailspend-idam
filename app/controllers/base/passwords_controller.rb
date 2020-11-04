# frozen_string_literal: true

module Base
  class PasswordsController < ApplicationController
    before_action :authenticate_user!, except: %i[new create confirm_new edit update password_reset_success]
    before_action :authorize_user, except: %i[new create confirm_new edit update password_reset_success]

    def new
      @response = Cognito::ForgotPassword.new(params[:email])
    end

    def create
      @response = Cognito::ForgotPassword.call(params[:email])
      if @response.success?
        redirect_to base_edit_user_password_path(email: params[:email])
      else
        flash[:error] = @response.error
        redirect_to base_new_user_password_path
      end
    end

    def edit
      @response = Cognito::ConfirmPasswordReset.new(params[:email], params[:password], params[:password_confirmation], params[:confirmation_code])
    end

    def update
      email = params[:user_email_reset_by_CSC].presence || params[:user_email_reset_by_themself]

      @response = Cognito::ConfirmPasswordReset.call(email, params[:password], params[:password_confirmation], params[:confirmation_code])
      if @response.success?
        redirect_to home_path
      else
        render :edit, erorr: @response.error
      end
    end

    def password_reset_success; end

    def confirm_new; end
  end
end

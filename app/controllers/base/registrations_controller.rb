# frozen_string_literal: true

module Base
  class RegistrationsController < ApplicationController
    protect_from_forgery

    def new
      @result = Cognito::SignUpUser.new
    end

    def create
      @result = Cognito::SignUpUser.call(sign_up_params)
      if @result.success?
        Rails.logger.info 'SIGN UP ATTEMPT SUCCESSFUL'
        redirect_to base_users_confirm_path(e: TextEncryptor.encrypt(sign_up_params[:email]))
      else
        fail_create
      end
    end

    def domain_not_on_allow_list; end

    private

    def fail_create
      if @result.not_on_allow_list
        Rails.logger.info 'SIGN UP ATTEMPT FAILED: Email domain not on allow list'
        redirect_to base_domain_not_on_allow_list_path
      else
        Rails.logger.info "SIGN UP ATTEMPT FAILED: #{get_error_list(@result.errors)}"
        render :new, erorr: @result.error
      end
    end

    def sign_up_params
      params.expect(
        cognito_sign_up_user: %i[
          email
          first_name
          last_name
          summary_line
          password
          password_confirmation
        ]
      )
    end
  end
end

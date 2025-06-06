# frozen_string_literal: true

module Base
  class SessionsController < ApplicationController
    skip_forgery_protection
    before_action :validate_filter

    def new
      @result = Cognito::SignInUser.new(nil, nil, nil, nil, nil)
    end

    # rubocop:disable Metrics/AbcSize
    def create
      @result = Cognito::SignInUser.new(sign_in_params[:email], sign_in_params[:password], params[:client_id], request.cookies.blank?, params[:redirect_uri])
      @result.call
      if @result.success?
        result = add_nonce(@result.cognito_user_response.authentication_result, params[:nonce])
        if result
          code = result
          cookies.permanent[:remember_token] = code
          Rails.logger.info 'SIGN IN ATTEMPT SUCCESSFUL'

          redirect_to("#{params[:redirect_uri]}?code=#{code}&state=#{params[:state]}", allow_other_host: true)
        end
      else
        result_unsuccessful_path
      end
    end
    # rubocop:enable Metrics/AbcSize

    protected

    def validate_filter
      redirect_to home_path if !params.key?(:client_id) || !params.key?(:state)
    end

    def result_unsuccessful_path
      # sign_out
      if @result.needs_password_reset
        Rails.logger.info 'SIGN IN ATTEMPT FAILED: Password reset required'
        redirect_to base_edit_user_password_path(e: TextEncryptor.encrypt(sign_in_params[:email]))
      elsif @result.needs_confirmation
        Rails.logger.info 'SIGN IN ATTEMPT FAILED: Password confirmation required'
        redirect_to base_users_confirm_path(e: TextEncryptor.encrypt(sign_in_params[:email]))
      else
        Rails.logger.info "SIGN IN ATTEMPT FAILED: #{get_error_list(@result.errors)}"
        render :new
      end
    end

    # rubocop:disable Metrics/AbcSize
    def add_nonce(cognito_response, client_nonce)
      decoded_token = JWT.decode cognito_response.id_token, nil, false
      decoded_token[0]['nonce'] = params[:nonce]

      id_token = JWT.encode decoded_token[0], nil, 'none'
      @client_call = ClientCall.new
      @client_call.access_token = cognito_response.access_token
      @client_call.refresh_token = cognito_response.refresh_token
      @client_call.id_token = id_token
      @client_call.token_type = cognito_response.token_type
      @client_call.expires_in = cognito_response.expires_in
      @client_call.sub = decoded_token[0]['sub']
      @client_call.nonce = client_nonce
      @client_call.save!
      get_saved_client(id_token)
    end
    # rubocop:enable Metrics/AbcSize

    def get_saved_client(token)
      result = ClientCall.find_by(id_token: token)
      result.id
    end

    def sign_in_params
      params.expect(
        cognito_sign_in_user: %i[
          email
          password
        ]
      )
    end
  end
end

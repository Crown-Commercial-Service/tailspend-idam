# frozen_string_literal: true

module Base
  class SessionsController < ApplicationController
    skip_forgery_protection
    before_action :authenticate_user!, except: %i[new create destroy]
    before_action :authorize_user, except: %i[new create destroy]
    before_action :validate_filter

    def new
      @result = Cognito::SignInUser.new(nil, nil, nil, nil)
    end

    # rubocop:disable Metrics/AbcSize
    def create
      @result = Cognito::SignInUser.new(request.POST[:anything][:email], request.POST[:anything][:password], params[:client_id], request.cookies.blank?)
      @result.call
      if @result.success?
        result = add_nonce(@result.cognito_user_response.authentication_result, params[:nonce])
        if result
          code = result
          cookies.permanent[:remember_token] = code
          redirect_to("#{params[:redirect_uri]}?code=#{code}&state=#{params[:state]}")
        end
      else
        result_unsuccessful_path
      end
    end
    # rubocop:enable Metrics/AbcSize

    def destroy
      # session.delete(current_user.id)
      # current_user.invalidate_session!
      # current_user.save!
      # super
    end

    protected

    def validate_filter
      redirect_to home_path if !params.key?(:client_id) || !params.key?(:state)
    end

    def after_sign_in_path_for(resource)
      stored_location_for(resource) || gateway_url
    end

    def after_sign_out_path_for(_resource)
      gateway_url
    end

    def authorize_user
      authorize! :read, SupplyTeachers
    end

    def result_unsuccessful_path
      # sign_out
      if @result.needs_password_reset
        redirect_to base_confirm_forgot_password_path(email:request.POST[:anything][:email])
      elsif @result.needs_confirmation
        redirect_to base_users_confirm_path(email:request.POST[:anything][:email])
      else
        render :new
      end
    end

    def build_nonce_jwt
      decoded_token = JWT.decode @result.cognito_user_response.authentication_result.id_token, nil, false
      decoded_token[0]['nonce'] = params[:nonce]
      JWT.encode decoded_token[0], nil, 'none'
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
  end
end

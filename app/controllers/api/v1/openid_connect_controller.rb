# frozen_string_literal: true

module Api
  module V1
    class OpenidConnectController < ::ApplicationController
      rescue_from Aws::CognitoIdentityProvider::Errors::NotAuthorizedException, with: :token_expired
      rescue_from ActiveRecord::RecordNotFound, with: :code_expired
      skip_before_action :verify_authenticity_token, only: %i[authorize token user_info]

      def authorize
        authorize = Cognito::Authorize.new(params['client_id'], params['response_type'], params['redirect_uri'])
        redirect_to(base_new_user_session_path(request.parameters)) if authorize.valid? && signed_in_user == false
      end

      def token
        result = ClientCall.find(params[:code].squish)
        data = build_authorize_response(result, result.nonce)
        render json: data
      end

      def user_info
        data = get_user_cognito(bearer_token)
        response_data = {}
        data.user_attributes.map { |attributes| response_data[attributes[:name]] = attributes[:value] }
        render json: response_data
      end

      private

      def token_expired
        error = 'Token has expired'
        render json: error
      end

      def code_expired
        error = 'Code has expired'
        render json: error
      end

      def signed_in_user
        false
        # puts cookies[:user]
        # if cookies[:user]
        #   return true
        # else
        #   return false
        # end
      end

      def build_authorize_response(cognito_response, nonce)
        {
          "access_token": cognito_response.access_token,
          "expires_in": cognito_response.expires_in,
          "token_type": cognito_response.token_type,
          "refresh_token": cognito_response.refresh_token,
          "id_token": cognito_response.id_token,
          "nonce": nonce.nil? ? '' : nonce
        }
      end

      def bearer_token
        pattern = /^Bearer /
        header  = request.headers['Authorization']
        header.gsub(pattern, '') if header&.match(pattern)
      end

      def get_user_cognito(token)
        client = Aws::CognitoIdentityProvider::Client.new(region: ENV['COGNITO_AWS_REGION'])
        client.get_user({
                          access_token: token
                        })
      end
    end
  end
end

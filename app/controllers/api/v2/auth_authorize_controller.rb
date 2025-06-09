# frozen_string_literal: true

module Api
  module V2
    class AuthAuthorizeController < ::ApplicationController
      rescue_from Aws::CognitoIdentityProvider::Errors::NotAuthorizedException, with: :token_expired
      rescue_from ActiveRecord::RecordNotFound, with: :code_expired
      skip_before_action :verify_authenticity_token, only: %i[authorize]

      def authorize
        authorize = Cognito::Authorize.new(params[:client_id], params[:response_type], params[:redirect_uri])
        redirect_to(base_new_user_session_path(request.parameters)) if authorize.valid? && signed_in_user? == false
      end

      private

      def signed_in_user?
        false
      end

      def token_expired
        error = 'Token has expired'
        render json: error
      end
    end
  end
end

module Api
  module V1
    class UserController < ::ApplicationController
      skip_before_action :verify_authenticity_token, only: %i[confirm_user create_user delete_user update_password_user]
      before_action :authenticate_token_user

      def delete_user
        client = Aws::CognitoIdentityProvider::Client.new(region: ENV['COGNITO_AWS_REGION'])
        response = []
        begin
          resp = client.admin_delete_user({
                                            user_pool_id: ENV['COGNITO_USER_POOL_ID'], # required
                                            username: params[:email], # required
                                          })
          response = ['User deleted']
        rescue StandardError => e
          Rails.logger.debug e
          response = ['There was an error']
        end

        render json: response
      end

      def update_password_user
        client = Aws::CognitoIdentityProvider::Client.new(region: ENV['COGNITO_AWS_REGION'])
        response = []
        begin
          resp = client.admin_set_user_password({
                                                  user_pool_id: ENV['COGNITO_USER_POOL_ID'], # required
                                                  username: params[:email], # required
                                                  password: params[:password], # required
                                                  permanent: true,
                                                })
          response = ['Password updated']
        rescue StandardError => e
          Rails.logger.debug e
          response = ['There was an error']
        end

        render json: response
      end

      def confirm_user
        client = Aws::CognitoIdentityProvider::Client.new(region: ENV['COGNITO_AWS_REGION'])
        response = []
        begin
          resp = client.admin_confirm_sign_up({
                                                user_pool_id: ENV['COGNITO_USER_POOL_ID'], # required
                                                username: params[:email], # required
                                              })
          response = ['User confirmed']
        rescue StandardError => e
          Rails.logger.debug e
          response = ['There was an error']
        end

        render json: response
      end

      def create_user
        client = Aws::CognitoIdentityProvider::Client.new(region: ENV['COGNITO_AWS_REGION'])
        response = []
        begin
          resp = client.admin_create_user({
                                            user_pool_id: ENV['COGNITO_USER_POOL_ID'], # required
                                            username: params[:email], # required
                                            user_attributes: [
                                              {
                                                name: 'email',
                                                value: params[:email]
                                              },
                                              {
                                                name: 'name',
                                                value: params[:first_name]
                                              },
                                              {
                                                name: 'family_name',
                                                value: params[:last_name]
                                              },
                                              {
                                                name: 'custom:organisation_name',
                                                value: params[:organisation]
                                              },
                                              # Some user do not have phone number so we add a dummy number
                                              # just so cognito can have a number cognito limitaions.
                                              {
                                                name: 'phone_number',
                                                value: '+4408654876588'
                                              },
                                              {
                                                name: 'email_verified',
                                                value: params[:email_verified]
                                              }
                                            ],

                                            temporary_password: params[:password],
                                            force_alias_creation: false,
                                            message_action: 'SUPPRESS',
                                          })
          response = ['User created']
        rescue StandardError => e
          Rails.logger.debug e
          response = ['There was an error']
        end

        render json: response
      end

      private

      def authenticate_token_user
        render json: ['Authentication failure'] if Cognito::Common.bearer_token(request) != ENV['AUTH_USER_API_TOKEN']
      end
    end
  end
end

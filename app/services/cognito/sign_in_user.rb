# frozen_string_literal: true

module Cognito
  class SignInUser < BaseService
    include ActiveModel::Validations

    attr_reader :email, :password, :cookies_disabled, :client_id, :redirect_uri
    attr_accessor :error, :needs_password_reset, :needs_confirmation

    validates_presence_of :email, :password
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
    validate :cookies_should_be_enabled, :redirect_uri_known

    def initialize(email, password, client_id, cookies_disabled, redirect_uri)
      super()
      @email = email.try(:downcase)
      @password = password
      @client_id = client_id
      @error = nil
      @needs_password_reset = false
      @cookies_disabled = cookies_disabled
      @redirect_uri = redirect_uri
    end

    def call
      initiate_auth if valid?
    rescue Aws::CognitoIdentityProvider::Errors::PasswordResetRequiredException => e
      @error = e.message
      errors.add(:base, e.message)
      @needs_password_reset = true
    rescue Aws::CognitoIdentityProvider::Errors::UserNotConfirmedException => e
      @error = e.message
      errors.add(:base, e.message)
      @needs_confirmation = true
    rescue Aws::CognitoIdentityProvider::Errors::ServiceError
      @error = I18n.t('base.users.sign_in_error')
      errors.add(:base, @error)
    end

    def cognito_user_response
      @auth_response
    end

    def success?
      @auth_response.present? && @error.nil?
    end

    private

    def initiate_auth
      go_then_wait do
        cognito_common = Cognito::Common.new
        client_creds = cognito_common.get_client_credentials(client_id)

        if client_creds.user_pool_client.explicit_auth_flows.intersect?(%w[USER_PASSWORD_AUTH ALLOW_USER_PASSWORD_AUTH])
          login_user_cognito(client_creds.user_pool_client.client_id, client_creds.user_pool_client.client_secret)
        else
          @error = I18n.t('base.users.sign_in_error')
          errors.add(:base, @error)
        end
      end
    end

    def login_user_cognito(client_id, client_secret)
      @auth_response = client.initiate_auth(
        client_id: @client_id,
        auth_flow: 'USER_PASSWORD_AUTH',
        auth_parameters: {
          'USERNAME' => email,
          'PASSWORD' => password,
          'SECRET_HASH' => Cognito::Common.build_client_secret_hash(email, client_id, client_secret)
        }
      )
    end

    def cookies_should_be_enabled
      errors.add(:base, :cookies_disabled) if @cookies_disabled
    end

    def redirect_uri_known
      errors.add(:base, :redirect_uri_mismatch) unless ENV['CALLBACK_URLS'].include?(@redirect_uri)
    end

    # This should keep the response times for attempting to log in with a fake or valid an account around the same length
    def go_then_wait
      finish_time = Time.now.in_time_zone('London') + MINIMUM_WAIT_TIME.second

      yield
    ensure
      sleep (finish_time - Time.now.in_time_zone('London')).clamp(0, MINIMUM_WAIT_TIME).seconds
    end

    MINIMUM_WAIT_TIME = 1
  end
end

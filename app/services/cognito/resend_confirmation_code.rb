# frozen_string_literal: true

module Cognito
  class ResendConfirmationCode < BaseService
    attr_reader :email
    attr_accessor :error

    def initialize(email)
      super()
      @email = email.try(:downcase)
      @error = nil
    end

    def call
      client.resend_confirmation_code(client_id: ENV.fetch('COGNITO_CLIENT_ID', nil), secret_hash: Cognito::Common.build_secret_hash(email), username: @email)
    rescue Aws::CognitoIdentityProvider::Errors::ServiceError => e
      @error = e.message
    end
  end
end

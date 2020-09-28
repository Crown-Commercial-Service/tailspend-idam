# frozen_string_literal: true

module Cognito
  class ResendConfirmationCode < BaseService
    attr_reader :email
    attr_accessor :error

    def initialize(email)
      super()
      @email = email
      @error = nil
    end

    def call
      client.resend_confirmation_code(client_id: ENV['COGNITO_CLIENT_ID'], secret_hash: Cognito::Common.build_secret_hash(email), username: @email)
    rescue Aws::CognitoIdentityProvider::Errors::ServiceError => e
      @error = e.message
    end

    def success?
      @error.nil?
    end

    private

    def username
      User.find_for_authentication(email: email).cognito_uuid
    end
  end
end

# frozen_string_literal: true

module Cognito
  class ForgotPassword < BaseService
    include ActiveModel::Validations
    attr_reader :email, :error

    validates :email, format: { with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i }

    def initialize(email)
      @email = email.try(:downcase)
      @error = nil
      super()
    end

    def call
      forgot_password if valid?
    rescue Aws::CognitoIdentityProvider::Errors::UserNotFoundException
      errors.add(:base, :user_not_found)
    rescue Aws::CognitoIdentityProvider::Errors::InvalidParameterException
      errors.add(:base, :user_not_found)
    rescue Aws::CognitoIdentityProvider::Errors::ServiceError => e
      errors.add(:base, e.message)
    end

    def success?
      errors.none?
    end

    private

    def forgot_password
      client.forgot_password(client_id: ENV['COGNITO_CLIENT_ID'], secret_hash: Cognito::Common.build_secret_hash(email), username: email)
    end
  end
end

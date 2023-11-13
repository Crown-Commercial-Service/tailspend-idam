# frozen_string_literal: true

module Cognito
  class ConfirmSignUp < BaseService
    include ActiveModel::Validations
    attr_reader :email, :confirmation_code
    attr_accessor :user

    validates :confirmation_code,
              presence: true,
              format: { with: /\A\d+\z/, message: :invalid_format },
              length: { is: 6, message: :invalid_length }
    validates_presence_of :email, :confirmation_code

    def initialize(params = {})
      super()
      @email = params[:email].try(:downcase)
      @confirmation_code = params[:confirmation_code]
      @error = nil
    end

    def call
      confirm_sign_up if valid?
    rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException
      # We do nothing as we don't want people to be able enumerate users
      errors.add(:confirmation_code, :invalid)
    rescue Aws::CognitoIdentityProvider::Errors::ServiceError => e
      errors.add(:confirmation_code, e.message)
    end

    def success?
      errors.none?
    end

    private

    def confirm_sign_up
      @response = client.confirm_sign_up(
        client_id: ENV.fetch('COGNITO_CLIENT_ID', nil),
        secret_hash: Cognito::Common.build_secret_hash(email),
        username: email,
        confirmation_code: confirmation_code
      )
    end
  end
end

# frozen_string_literal: true

module Cognito
  class ConfirmPasswordReset < BaseService
    include ActiveModel::Validations
    attr_reader :email, :password, :password_confirmation, :confirmation_code

    include PasswordValidator

    validates :confirmation_code, presence: true

    def initialize(params = {})
      super()
      @email = params[:email].try(:downcase)
      @password = params[:password]
      @password_confirmation = params[:password_confirmation]
      @confirmation_code = params[:confirmation_code]
    end

    def call
      if valid?
        create_user_if_needed
        confirm_forgot_password
      end
    rescue Aws::CognitoIdentityProvider::Errors::CodeMismatchException => e
      errors.add(:confirmation_code, e.message)
    rescue Aws::CognitoIdentityProvider::Errors::ServiceError => e
      errors.add(:base, e.message)
    end

    def success?
      errors.none?
    end

    private

    def confirm_forgot_password
      @response = client.confirm_forgot_password(
        client_id: ENV['COGNITO_CLIENT_ID'],
        secret_hash: Cognito::Common.build_secret_hash(email),
        username: email,
        password: password,
        confirmation_code: confirmation_code
      )
    end

    def create_user_if_needed
      # user = User.find_for_authentication(email: email)
      # return user if user

      resp = CreateUserFromCognito.call(email)
      if resp.success?
        resp.user
      else
        errors.add(:base, I18n.t('activemodel.errors.models.cognito/confirm_password_reset.user_not_found'))
      end
    end
  end
end

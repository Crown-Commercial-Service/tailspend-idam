# frozen_string_literal: true

module Cognito
  class CreateUserFromCognito < BaseService
    attr_reader :email
    attr_accessor :error, :user

    def initialize(email)
      super()
      @email = email.try(:downcase)
      @error = nil
    end

    def call
      @cognito_user = client.admin_get_user(user_pool_id: ENV.fetch('COGNITO_USER_POOL_ID', nil), username: email)
      @cognito_uuid = cognito_attribute('sub')
      @cognito_user_groups = client.admin_list_groups_for_user(user_pool_id: ENV.fetch('COGNITO_USER_POOL_ID', nil), username: @cognito_uuid)
    rescue Aws::CognitoIdentityProvider::Errors::ServiceError => e
      @error = e.message
    end

    private

    def cognito_attribute(attr)
      @cognito_user.user_attributes.find { |u| u.name == attr }.try(:value)
    end
  end
end

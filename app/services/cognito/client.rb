# frozen_string_literal: true

module Cognito
  class Client < BaseService
    include ActiveModel::Validations
    attr_reader :client_id
    attr_accessor :error

    validates_presence_of :client_id

    def initialize(client_id)
      super()
      @client_id = client_id
      @error = nil
    end

    def call
      describe_user_pool_client if valid?
    end

    def cognito_user_response
      @auth_response
    end

    def success?
      @auth_response.present? && @error.nil?
    end

    private

    def describe_user_pool_client
      @auth_response = client.describe_user_pool_client(
        user_pool_id: ENV['COGNITO_USER_POOL_ID'],
        client_id: @client_id,
      )
    end
  end
end

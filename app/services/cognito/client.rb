# frozen_string_literal: true

module Cognito
  class Client < BaseService
    include ActiveModel::Validations
    attr_reader :client_id

    validates_presence_of :client_id

    def initialize(client_id)
      super()
      @client_id = client_id
      @error = nil
    end

    def call
      describe_user_pool_client if valid?
    end

    def cognito_client_response
      @client_response
    end

    def success?
      @client_response.present? && @error.nil?
    end

    private

    def describe_user_pool_client
      @client_response = client.describe_user_pool_client(
        user_pool_id: ENV.fetch('COGNITO_USER_POOL_ID', nil),
        client_id: @client_id,
      )
    end
  end
end

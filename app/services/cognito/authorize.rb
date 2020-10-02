module Cognito
  class Authorize < BaseService
    include ActiveModel::Validations
    attr_reader :client_id, :response_type, :redirect_uri

    validates_presence_of :client_id, :response_type, :redirect_uri
    validate :must_be_client

    def initialize(client_id, response_type, redirect_uri)
      super()
      @client_id = client_id
      @response_type = response_type
      @redirect_uri = redirect_uri
      @error = nil
    end

    def must_be_client
      cognito_common = Cognito::Common.new
      cognito_common.get_client_credentials(@client_id)
    rescue StandardError
      error_msg = I18n.t('api.v1.openid.errors.client_id')
      errors.add(:client_id, error_msg)
    end
  end
end

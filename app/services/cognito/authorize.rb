module Cognito
  class Authorize < BaseService
    include ActiveModel::Validations
    attr_reader :client_id, :response_type, :redirect_uri

    validates_presence_of :client_id, :response_type, :redirect_uri
    validate :must_be_client

    def initialize(client_id, response_type, redirect_uri, nonce)
      super()
      @client_id = client_id
      @response_type = response_type
      @redirect_uri = redirect_uri
      @nonce = nonce
      @error = nil
    end

    def must_be_client
      response = HTTParty.get("#{ENV['COGNITO_URL']}/oauth2/authorize?response_type=code&redirect_uri=#{ENV['COGNITO_REDIRECT_URL']}&nonce=#{@nonce}&client_id=#{ENV['COGNITO_CLIENT_ID']}&scope=openid+profile&state=STATE")
      errors.add(:client_id, I18n.t('api.v1.openid.errors.client_id')) unless response.code == 200
    rescue StandardError
      error_msg = I18n.t('api.v1.openid.errors.client_id')
      errors.add(:client_id, error_msg)
    end
  end
end

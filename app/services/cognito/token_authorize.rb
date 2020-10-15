module Cognito
  class TokenAuthorize < BaseService
    include ActiveModel::Validations
    attr_reader :client_id, :client_id, :redirect_uri, :grant_type, :code

    validates_presence_of :client_id, :client_secret, :redirect_uri, :grant_type
    validate :must_be_client

    def initialize(client_id, client_secret, redirect_uri, grant_type, code)
      super()
      @client_id = client_id
      @client_secret = client_secret
      @redirect_uri = redirect_uri
      @grant_type = grant_type
      @code = code
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

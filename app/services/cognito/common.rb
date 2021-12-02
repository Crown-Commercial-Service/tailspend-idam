# frozen_string_literal: true

module Cognito
  class Common < BaseService
    def self.build_secret_hash(email)
      build_client_secret_hash(email, ENV['COGNITO_CLIENT_ID'], ENV['COGNITO_CLIENT_SECRET'])
    end

    # if client has a secret we need to use that to build thier secret for cognito
    def self.build_client_secret_hash(email, client_id, client_secret)
      key = client_secret
      data = email + client_id
      Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), key, data)).strip
    end

    def get_client_credentials(client_id)
      client.describe_user_pool_client(
        user_pool_id: ENV['COGNITO_USER_POOL_ID'],
        client_id: client_id,
      )
    end

    def self.bearer_token(request)
      pattern = /^Bearer /
      header  = request.headers['Authorization']
      header.gsub(pattern, '') if header&.match(pattern)
    end
  end
end

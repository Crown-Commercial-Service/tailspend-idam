# frozen_string_literal: true

module Cognito
  class Common < BaseService
    def self.build_secret_hash(email)
      key = ENV['COGNITO_CLIENT_SECRET']
      data = email + ENV['COGNITO_CLIENT_ID']
      Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), key, data)).strip
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

    def sign_out_user(token)
      client.global_sign_out({
                               access_token: token,
                             })
    end
  end
end

# frozen_string_literal: true

module Cognito
  class Common < BaseService
    def self.build_secret_hash(email)
      key = ENV['COGNITO_CLIENT_SECRET']
      data = email + ENV['COGNITO_CLIENT_ID']
      Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), key, data)).strip
    end
  end
end

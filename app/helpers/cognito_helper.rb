# frozen_string_literal: true

module CognitoHelper
  def build_secret_hash(email)
    key = ENV['COGNITO_CLIENT_SECRET'] # (get this from amazon cognito console)
    data = email + ENV['COGNITO_CLIENT_ID'] # (get App_client_id from amazon console)
    Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), key, data)).strip
  end
end

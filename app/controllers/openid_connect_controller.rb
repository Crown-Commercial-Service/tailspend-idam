# frozen_string_literal: true

class OpenidConnectController < ApplicationController
  include ActiveModel::Validations
  rescue_from Aws::CognitoIdentityProvider::Errors::ResourceNotFoundException, with: :client_id_error # self defined exception
  skip_before_action :verify_authenticity_token

  def authorize
    redirect_to(base_new_user_session_path(request.parameters))
  end

  def token
    result = ClientCall.find(params[:code].squish)
    data = build_authorize_response(result, result.nonce)
    render json: data
  end

  private

  def client_id_error
    error = 'Clinet not recognized'
    render json: error
  end

  def fail_create(result)
    if result.not_on_whitelist
      redirect_to base_domain_not_on_whitelist_path
    else
      render :new, erorr: result.error
    end
  end

  def sign_in_user
    false
    # puts cookies[:user]
    # if cookies[:user]
    #   return true
    # else
    #   return false
    # end
  end

  def add_nonce(access_token, client_nonce)
    ClientCall.find_or_create_by(token: access_token) do |c|
      c.token = access_token
      c.nonce = client_nonce
    end
  end

  def build_authorize_response(cognito_response, nonce)
    {
      "access_token": cognito_response.token,
      "expires_in": cognito_response.expires_in,
      "token_type": cognito_response.token_type,
      "refresh_token": cognito_response.refresh_token,
      "id_token": cognito_response.id_token,
      "nonce": nonce.nil? ? '' : nonce
    }
  end

  def bearer_token
    pattern = /^Bearer /
    header  = request.headers['Authorization']
    header.gsub(pattern, '') if header&.match(pattern)
  end

  def get_user_cognito(token)
    client = Aws::CognitoIdentityProvider::Client.new(region: ENV['COGNITO_AWS_REGION'])
    client.get_user({
                      access_token: token
                    })
  end
end

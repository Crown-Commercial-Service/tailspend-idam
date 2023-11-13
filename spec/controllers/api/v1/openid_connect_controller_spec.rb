require 'rails_helper'

RSpec.describe Api::V1::OpenidConnectController do
  let(:client_id) { 'CLIENT_ID' }
  let(:response_type) { 'code' }
  let(:redirect_uri) { 'https://example.com' }

  describe 'GET authorize' do
    let(:cognito_authorize) { instance_double(Cognito::Authorize) }

    before { allow(Cognito::Authorize).to receive(:new).with(client_id, response_type, redirect_uri).and_return(cognito_authorize) }

    context 'when not authorized' do
      before do
        allow(cognito_authorize).to receive(:valid?).and_raise(Aws::CognitoIdentityProvider::Errors::NotAuthorizedException.new('Some error', 'Some message'))

        get :authorize, params: { client_id:, response_type:, redirect_uri: }
      end

      it 'responds with token has expired' do
        expect(response.body).to eq('Token has expired')
      end
    end

    context 'when authorized but not valid' do
      before do
        allow(cognito_authorize).to receive(:valid?).and_return(false)

        get :authorize, params: { client_id:, response_type:, redirect_uri: }
      end

      it 'renders authorize' do
        expect(response).to render_template(:authorize)
      end
    end

    context 'when authorized' do
      before do
        allow(cognito_authorize).to receive(:valid?).and_return(true)

        get :authorize, params: { client_id:, response_type:, redirect_uri: }
      end

      it 'redirect_to base_new_user_session_path' do
        expect(response).to redirect_to(base_new_user_session_path('action' => 'authorize', client_id: client_id, 'controller' => 'api/v1/openid_connect', redirect_uri: redirect_uri, response_type: response_type))
      end
    end

    describe 'GET token' do
      let(:client_call_id) { SecureRandom.uuid }
      let(:client_call) do
        ClientCall.create(
          id: client_call_id,
          access_token: 'access_token',
          refresh_token: 'refresh_token',
          id_token: 'eyJhbGciOiJub25lIn0.eyJpZF90b2tlbiI6ImlkX3Rva2VuIiwic3ViIjoic3ViIiwibm9uY2UiOiJOT05DRSJ9.',
          token_type: 'token_type',
          expires_in: 'expires_in',
          sub: 'sub',
          client_id: nil,
          nonce: nonce
        )
      end

      context 'when it cannot find the client call' do
        before { put :token, params: { code: client_call_id } }

        it 'responds with code has expired' do
          expect(response.body).to eq('Code has expired')
        end
      end

      # rubocop:disable RSpec/NestedGroups
      context 'when it can find the client call' do
        let(:response_body) { response.parsed_body }

        before do
          client_call
          put :token, params: { code: client_call_id }
        end

        context 'when the nonce is nil' do
          let(:nonce) { nil }

          it 'responds with the JSON data' do
            expect(response_body).to eq(
              {
                'access_token' => 'access_token',
                'expires_in' => 'expires_in',
                'token_type' => 'token_type',
                'refresh_token' => 'refresh_token',
                'id_token' => 'eyJhbGciOiJub25lIn0.eyJpZF90b2tlbiI6ImlkX3Rva2VuIiwic3ViIjoic3ViIiwibm9uY2UiOiJOT05DRSJ9.',
                'nonce' => ''
              }
            )
          end
        end

        context 'when the nonce is not nil' do
          let(:nonce) { 'NONCE' }

          it 'responds with the JSON data' do
            expect(response_body).to eq(
              {
                'access_token' => 'access_token',
                'expires_in' => 'expires_in',
                'token_type' => 'token_type',
                'refresh_token' => 'refresh_token',
                'id_token' => 'eyJhbGciOiJub25lIn0.eyJpZF90b2tlbiI6ImlkX3Rva2VuIiwic3ViIjoic3ViIiwibm9uY2UiOiJOT05DRSJ9.',
                'nonce' => 'NONCE'
              }
            )
          end
        end
      end
      # rubocop:enable RSpec/NestedGroups
    end
  end

  describe 'GET user_info' do
    let(:cognito_identity_provider_client) { instance_double(Aws::CognitoIdentityProvider::Client) }
    let(:access_token) { 'AccessToken' }

    before do
      get_user_struct = Struct.new(:user_attributes, keyword_init: true)
      user_attribute_struct = Struct.new(:name, :value, keyword_init: true)

      allow(Aws::CognitoIdentityProvider::Client).to receive(:new).and_return(cognito_identity_provider_client)
      allow(cognito_identity_provider_client).to receive(:get_user).with({ access_token: }).and_return(
        get_user_struct.new(
          user_attributes: [
            user_attribute_struct.new(name: 'email', value: 'dc@email.com'),
            user_attribute_struct.new(name: 'name', value: 'David'),
            user_attribute_struct.new(name: 'family_name', value: 'Cohen'),
            user_attribute_struct.new(name: 'custom:organisation_name', value: 'CCS'),
          ]
        )
      )
    end

    it 'responds with the user attributes' do
      request.headers['Authorization'] = "Bearer #{access_token}"

      get :user_info

      expect(response.parsed_body).to eq(
        {
          'email' => 'dc@email.com',
          'name' => 'David',
          'family_name' => 'Cohen',
          'custom:organisation_name' => 'CCS',
        }
      )
    end
  end
end

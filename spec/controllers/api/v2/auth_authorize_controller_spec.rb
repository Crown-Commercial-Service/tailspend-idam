require 'rails_helper'

RSpec.describe Api::V2::AuthAuthorizeController do
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
      before { allow(cognito_authorize).to receive(:valid?).and_return(false) }

      it 'raises the MissingExactTemplate error' do
        expect do
          get :authorize, params: { client_id:, response_type:, redirect_uri: }
        end.to raise_error(ActionController::MissingExactTemplate)
      end
    end

    context 'when authorized' do
      before do
        allow(cognito_authorize).to receive(:valid?).and_return(true)

        get :authorize, params: { client_id:, response_type:, redirect_uri: }
      end

      it 'redirect_to base_new_user_session_path' do
        expect(response).to redirect_to(base_new_user_session_path('action' => 'authorize', client_id: client_id, 'controller' => 'api/v2/auth_authorize', redirect_uri: redirect_uri, response_type: response_type))
      end
    end
  end
end

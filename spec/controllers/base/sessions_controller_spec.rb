require 'rails_helper'

RSpec.describe Base::SessionsController do
  let(:client_id) { 'CLIENT_ID' }
  let(:state) { 'STATE' }
  let(:redirect_uri) { 'https://example.com' }
  let(:email) { 'email@email.com' }
  let(:encrypted_email) { 'ENCRYPTED_EMAIL' }
  let(:password) { 'Password1234' }
  let(:nonce) { 'NONCE' }

  describe 'GET new' do
    context 'when the client_id is not present' do
      before { get :new, params: { state: } }

      it 'redirects to the home path' do
        expect(response).to redirect_to home_path
      end
    end

    context 'when the state is not present' do
      before { get :new, params: { client_id: } }

      it 'redirects to the home path' do
        expect(response).to redirect_to home_path
      end
    end

    context 'when the client_id and state is not present' do
      before { get :new }

      it 'redirects to the home path' do
        expect(response).to redirect_to home_path
      end
    end

    context 'when the client_id and state are present' do
      before { get :new, params: { client_id:, state: } }

      it 'renders the new page' do
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'POST create' do
    let(:cognito_sign_in_user) { instance_double(Cognito::SignInUser) }

    before do
      allow(Cognito::SignInUser).to receive(:new).and_return(cognito_sign_in_user)
      allow(cognito_sign_in_user).to receive(:call)
      allow(TextEncryptor).to receive(:encrypt).with(email).and_return(encrypted_email)
      allow(TextEncryptor).to receive(:decrypt).with(encrypted_email).and_return(email)
    end

    context 'when the call is not successful' do
      before { allow(cognito_sign_in_user).to receive(:success?).and_return(false) }

      context 'and it is because it needs password reset' do
        before do
          allow(cognito_sign_in_user).to receive(:needs_password_reset).and_return(true)

          post :create, params: { cognito_sign_in_user: { email:, password: }, client_id: client_id, state: state, redirect_uri: redirect_uri }
        end

        it 'redirects to the base_confirm_forgot_password_path' do
          expect(response).to redirect_to base_edit_user_password_path(e: encrypted_email)
        end
      end

      context 'and it is because it needs confirmation' do
        before do
          allow(cognito_sign_in_user).to receive_messages(
            needs_password_reset: false,
            needs_confirmation: true
          )

          post :create, params: { cognito_sign_in_user: { email:, password: }, client_id: client_id, state: state, redirect_uri: redirect_uri }
        end

        it 'redirects to the base_users_confirm_path' do
          expect(response).to redirect_to base_users_confirm_path(e: encrypted_email)
        end
      end

      context 'and it is because something is invalid' do
        before do
          errors = instance_double(ActiveModel::Errors)

          allow(cognito_sign_in_user).to receive_messages(
            needs_password_reset: false,
            needs_confirmation: false,
            errors: errors
          )
          allow(errors).to receive(:details).and_return({})

          post :create, params: { cognito_sign_in_user: { email:, password: }, client_id: client_id, state: state, redirect_uri: redirect_uri }
        end

        it 'renders the new page' do
          expect(response).to render_template(:new)
        end
      end
    end

    context 'when the call is successful' do
      let(:code) { 'hello' }
      let(:client_call) { ClientCall.first }

      before do
        cognito_user_response = instance_double(Aws::CognitoIdentityProvider::Types::InitiateAuthResponse)
        authentication_result = instance_double(Aws::CognitoIdentityProvider::Types::AuthenticationResultType)

        allow(cognito_sign_in_user).to receive_messages(
          success?: true,
          cognito_user_response: cognito_user_response
        )
        allow(cognito_user_response).to receive(:authentication_result).and_return(authentication_result)
        allow(authentication_result).to receive_messages(
          id_token: 'eyJhbGciOiJub25lIn0.eyJpZF90b2tlbiI6ImlkX3Rva2VuIiwic3ViIjoic3ViIn0.',
          access_token: 'access_token',
          refresh_token: 'refresh_token',
          token_type: 'token_type',
          expires_in: 'expires_in',
        )
      end

      it 'redirects to the redirect uri' do
        post :create, params: { cognito_sign_in_user: { email:, password: }, client_id: client_id, state: state, redirect_uri: redirect_uri }

        expect(response).to redirect_to("https://example.com?code=#{client_call.id}&state=#{state}")
      end

      it 'updates the remember_token cookie' do
        post :create, params: { cognito_sign_in_user: { email:, password: }, client_id: client_id, state: state, redirect_uri: redirect_uri }

        expect(response.cookies['remember_token']).to eq(client_call.id)
      end

      it 'creates a client call' do
        expect do
          post :create, params: { cognito_sign_in_user: { email:, password: }, client_id: client_id, state: state, redirect_uri: redirect_uri }
        end.to change(ClientCall, :count).by(1)
      end

      # rubocop:disable RSpec/ExampleLength
      it 'sets the right data in the client call' do
        post :create, params: { cognito_sign_in_user: { email:, password: }, client_id: client_id, state: state, redirect_uri: redirect_uri, nonce: nonce }

        expect(client_call.attributes.except('id', 'created_at', 'updated_at')).to eq(
          {
            'access_token' => 'access_token',
            'refresh_token' => 'refresh_token',
            'id_token' => 'eyJhbGciOiJub25lIn0.eyJpZF90b2tlbiI6ImlkX3Rva2VuIiwic3ViIjoic3ViIiwibm9uY2UiOiJOT05DRSJ9.',
            'token_type' => 'token_type',
            'expires_in' => 'expires_in',
            'sub' => 'sub',
            'client_id' => nil,
            'nonce' => nonce
          }
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end

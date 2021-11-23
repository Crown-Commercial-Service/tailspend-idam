require 'rails_helper'

RSpec.describe Base::UsersController do
  describe 'GET confirm_new' do
    before { get :confirm_new }

    it 'renders the confirm_new page' do
      expect(response).to render_template(:confirm_new)
    end
  end

  describe 'POST confirm' do
    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Cognito::ConfirmSignUp).to receive(:confirm_sign_up).and_return(true)
      # rubocop:enable RSpec/AnyInstance
      post :confirm, params: { cognito_confirm_sign_up: { email: 'test@testemail.com', confirmation_code: confirmation_code } }
    end

    context 'when the information is invalid' do
      let(:confirmation_code) { '' }

      it 'renders confirm_new' do
        expect(response).to render_template(:confirm_new)
      end
    end

    context 'when the information is valid' do
      let(:confirmation_code) { '123456' }

      it 'redirects to the sign in page' do
        expect(response).to redirect_to base_new_user_session_path
      end
    end
  end

  describe 'GET resend_confirmation_email' do
    let(:email) { 'test@testemail.com' }

    before do
      allow(Cognito::ResendConfirmationCode).to receive(:call).with(email).and_return(Cognito::ResendConfirmationCode.new(email))
      get :resend_confirmation_email, params: { email: email }
    end

    it 'redirects to the confirm page' do
      expect(response).to redirect_to base_users_confirm_path_path(email: email)
    end
  end
end

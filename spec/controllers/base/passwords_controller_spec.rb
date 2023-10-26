require 'rails_helper'

RSpec.describe Base::PasswordsController do
  describe 'GET new' do
    before { get :new }

    it 'renders the new page' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST create' do
    context 'when no exception is raised' do
      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(Cognito::ForgotPassword).to receive(:forgot_password).and_return(true)
        # rubocop:enable RSpec/AnyInstance
        post :create, params: { cognito_forgot_password: { email: } }
      end

      context 'when the email is invalid' do
        let(:email) { 'testtest.com' }

        it 'render to the new page' do
          expect(response).to render_template(:new)
        end
      end

      context 'when the email is valid' do
        let(:email) { 'test@test.com' }

        it 'redirects to the edit password page' do
          expect(response.location.split('=')[0]).to eq "#{base_edit_user_password_url}?e"
        end
      end
    end

    context 'when the email is valid but an exception is raised' do
      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(Cognito::ForgotPassword).to receive(:forgot_password).and_raise(error.new('Some context', 'Some message'))
        # rubocop:enable RSpec/AnyInstance
        post :create, params: { cognito_forgot_password: { email: 'test@test.com' } }
      end

      context 'and the error is UserNotFoundException' do
        let(:error) { Aws::CognitoIdentityProvider::Errors::UserNotFoundException }

        it 'redirects to the edit password page' do
          expect(response.location.split('=')[0]).to eq "#{base_edit_user_password_url}?e"
        end
      end

      context 'and the error is InvalidParameterException' do
        let(:error) { Aws::CognitoIdentityProvider::Errors::InvalidParameterException }

        it 'render to the new page' do
          expect(response).to render_template(:new)
        end
      end

      context 'and the error is ServiceError' do
        let(:error) { Aws::CognitoIdentityProvider::Errors::ServiceError }

        it 'render to the new page' do
          expect(response).to render_template(:new)
        end
      end
    end
  end

  describe 'GET edit' do
    before { get :edit, params: { e: TextEncryptor.encrypt('test@email.com') } }

    it 'renders the edit page' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'PUT update' do
    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Cognito::ConfirmPasswordReset).to receive(:create_user_if_needed).and_return(true)
      allow_any_instance_of(Cognito::ConfirmPasswordReset).to receive(:confirm_forgot_password).and_return(true)
      # rubocop:enable RSpec/AnyInstance
      put :update, params: { cognito_confirm_password_reset: { email: 'test@test.com', password: password, password_confirmation: password, confirmation_code: '123456' } }
    end

    context 'when the reset password is invalid' do
      let(:password) { 'Pas12!' }

      it 'renders the edit page' do
        expect(response).to render_template(:edit)
      end
    end

    context 'when the reset password is valid' do
      let(:password) { generate_random_valid_password }

      it 'redirects to the home page' do
        expect(response).to redirect_to home_path
      end
    end
  end
end

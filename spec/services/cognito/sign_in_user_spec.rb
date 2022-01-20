require 'rails_helper'

RSpec.describe Cognito::SignInUser do
  let(:sign_in_user) { described_class.new(email, password, nil, false) }
  let(:email) { 'test@test.com' }
  let(:password) { 'password123!' }

  describe '.valid?' do
    context 'when both email and password are present' do
      it 'is valid' do
        expect(sign_in_user.valid?).to be true
      end
    end

    context 'when considering the email' do
      context 'and it is blank' do
        let(:email) { '' }

        it 'is not valid' do
          expect(sign_in_user.valid?).to be false
        end

        it 'has the correct error message' do
          sign_in_user.valid?
          expect(sign_in_user.errors[:email].first).to eq 'You must enter your email address in the correct format, like name@example.com'
        end
      end

      context 'and it is not in the correct format' do
        let(:email) { 'admin' }

        it 'is not valid' do
          expect(sign_in_user.valid?).to be false
        end

        it 'has the correct error message' do
          sign_in_user.valid?
          expect(sign_in_user.errors[:email].first).to eq 'You must enter your email address in the correct format, like name@example.com'
        end
      end
    end

    context 'when considering the password' do
      context 'and it is blank' do
        let(:password) { '' }

        it 'is not valid' do
          expect(sign_in_user.valid?).to be false
        end

        it 'has the correct error message' do
          sign_in_user.valid?
          expect(sign_in_user.errors[:password].first).to eq 'You must enter your password'
        end
      end
    end
  end

  describe 'initialisation of email' do
    context 'when the email contains capital letters' do
      let(:email) { 'Test@TeST.com' }

      it 'will become downcased when the object is initialised' do
        expect(sign_in_user.email).to eq 'test@test.com'
      end
    end
  end

  describe '.call' do
    let(:client) { instance_double(Aws::CognitoIdentityProvider::Client) }

    before do
      stub_const('ENV', { 'COGNITO_AWS_REGION' => 'supersecretregion', 'COGNITO_CLIENT_SECRET' => 'supersecretkey1', 'COGNITO_CLIENT_ID' => 'supersecretkey2' })
      allow(Aws::CognitoIdentityProvider::Client).to receive(:new).with(region: 'supersecretregion').and_return(client)
    end

    context 'when the details are valid' do
      let(:client_creds) { double }
      let(:user_pool_client) { double }
      let(:auth_response) { double }

      before do
        allow(client).to receive(:describe_user_pool_client).and_return(client_creds)
        allow(client_creds).to receive(:user_pool_client).and_return(user_pool_client)
        allow(user_pool_client).to receive(:explicit_auth_flows).and_return(explicit_auth_flows)
      end

      context 'and the explicit_auth_flows includes "USER_PASSWORD_AUTH"' do
        let(:explicit_auth_flows) { ['USER_PASSWORD_AUTH'] }

        before do
          allow(user_pool_client).to receive(:client_id).and_return('supersecretkey2')
          allow(user_pool_client).to receive(:client_secret).and_return('supersecretkey1')
          allow(client).to receive(:initiate_auth).and_return(auth_response)
          sign_in_user.call
        end

        it 'calls initiate_auth on the client' do
          expect(client).to have_received(:initiate_auth).with(
            client_id: nil,
            auth_flow: 'USER_PASSWORD_AUTH',
            auth_parameters: {
              'USERNAME' => email,
              'PASSWORD' => password,
              'SECRET_HASH' => 'QGGa3OLislakJW63OXujsIzjOxqYgSxptyRHAuyobd8='
            }
          )
        end

        it 'sets the auth_response' do
          expect(sign_in_user.cognito_user_response).to eq auth_response
        end
      end

      context 'and the explicit_auth_flows does not include "USER_PASSWORD_AUTH"' do
        let(:explicit_auth_flows) { [] }

        before { sign_in_user.call }

        it 'sets the error and success will be false' do
          expect(sign_in_user.errors[:base].first).to eq 'You must provide a correct username or password'
          expect(sign_in_user.success?).to be false
        end
      end
    end

    context 'when an error is raised' do
      let(:message) { 'Some message' }

      before do
        allow(client).to receive(:describe_user_pool_client).and_raise(error.new('Some context', message))
        sign_in_user.call
      end

      context 'and the error is PasswordResetRequiredException' do
        let(:error) { Aws::CognitoIdentityProvider::Errors::PasswordResetRequiredException }

        it 'sets the error, success will be false and needs_password_reset will be true' do
          expect(sign_in_user.errors[:base].first).to eq 'Some message'
          expect(sign_in_user.success?).to be false
          expect(sign_in_user.instance_variable_get(:@needs_password_reset)).to be true
        end
      end

      context 'and the error is UserNotConfirmedException' do
        let(:error) { Aws::CognitoIdentityProvider::Errors::UserNotConfirmedException }

        it 'sets the error, success will be false and needs_confirmation will be true' do
          expect(sign_in_user.errors[:base].first).to eq 'Some message'
          expect(sign_in_user.success?).to be false
          expect(sign_in_user.instance_variable_get(:@needs_confirmation)).to be true
        end
      end

      context 'and the error is UserNotFoundException' do
        let(:error) { Aws::CognitoIdentityProvider::Errors::UserNotFoundException }

        it 'sets the error and success will be false' do
          expect(sign_in_user.errors[:base].first).to eq 'You must provide a correct username or password'
          expect(sign_in_user.success?).to be false
        end
      end

      context 'and the error is NotAuthorizedException' do
        let(:message) { 'Incorrect username or password.' }
        let(:error) { Aws::CognitoIdentityProvider::Errors::NotAuthorizedException }

        it 'sets the error and success will be false' do
          expect(sign_in_user.errors[:base].first).to eq 'You must provide a correct username or password'
          expect(sign_in_user.success?).to be false
        end
      end

      context 'and the error is NotAuthorizedException with too many attempts exception' do
        let(:message) { 'Password attempt limit exceeded.' }
        let(:error) { Aws::CognitoIdentityProvider::Errors::NotAuthorizedException }

        it 'sets the error and success will be false' do
          expect(sign_in_user.errors[:base].first).to eq 'Password attempt limit exceeded.'
          expect(sign_in_user.success?).to be false
        end
      end

      context 'and the error is ServiceError' do
        let(:error) { Aws::CognitoIdentityProvider::Errors::ServiceError }

        it 'sets the error and success will be false' do
          expect(sign_in_user.errors[:base].first).to eq 'You must provide a correct username or password'
          expect(sign_in_user.success?).to be false
        end
      end
    end
  end
end

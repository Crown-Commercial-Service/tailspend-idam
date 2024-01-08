require 'rails_helper'

RSpec.describe Cognito::ConfirmSignUp do
  let(:confirm_sign_up) { described_class.new(params) }

  let(:params) do
    {
      email:,
      confirmation_code:
    }
  end

  let(:email) { 'test@test.com' }
  let(:confirmation_code) { '123456' }

  describe '.valid?' do
    context 'when all attributes are valid' do
      it 'is valid' do
        expect(confirm_sign_up.valid?).to be true
      end
    end

    context 'when considering the email' do
      context 'and it is blank' do
        let(:email) { '' }

        it 'is not valid' do
          expect(confirm_sign_up.valid?).to be false
        end

        it 'has the correct error message' do
          confirm_sign_up.valid?
          expect(confirm_sign_up.errors[:email].first).to eq 'You must enter your email address in the correct format, like name@example.com'
        end
      end
    end

    context 'when considering the confirmation_code' do
      context 'and it is blank' do
        let(:confirmation_code) { '' }

        it 'is not valid' do
          expect(confirm_sign_up.valid?).to be false
        end

        it 'has the correct error message' do
          confirm_sign_up.valid?
          expect(confirm_sign_up.errors[:confirmation_code].first).to eq 'Enter your verification code'
        end
      end

      context 'and it contains non numeric characters' do
        let(:confirmation_code) { '12£4S6' }

        it 'is not valid' do
          expect(confirm_sign_up.valid?).to be false
        end

        it 'has the correct error message' do
          confirm_sign_up.valid?
          expect(confirm_sign_up.errors[:confirmation_code].first).to eq 'Confirmation code must contain numeric characters only'
        end
      end

      context 'and it is too short' do
        let(:confirmation_code) { '12345' }

        it 'is not valid' do
          expect(confirm_sign_up.valid?).to be false
        end

        it 'has the correct error message' do
          confirm_sign_up.valid?
          expect(confirm_sign_up.errors[:confirmation_code].first).to eq 'Confirmation code must be 6 characters'
        end
      end
    end
  end

  describe 'initialisation of email' do
    context 'when the email contains capital letters' do
      let(:email) { 'Test@TeST.com' }

      it 'becomes downcased when the object is initialised' do
        expect(confirm_sign_up.email).to eq 'test@test.com'
      end
    end
  end

  describe '.call' do
    let(:client) { instance_double(Aws::CognitoIdentityProvider::Client) }

    before do
      stub_const('ENV', { 'COGNITO_AWS_REGION' => 'supersecretregion', 'COGNITO_CLIENT_SECRET' => 'supersecretkey1', 'COGNITO_CLIENT_ID' => 'supersecretkey2' })
      allow(Aws::CognitoIdentityProvider::Client).to receive(:new).with(region: 'supersecretregion').and_return(client)
    end

    context 'when there are no errors' do
      before do
        allow(client).to receive(:confirm_sign_up)
        confirm_sign_up.call
      end

      it 'calls the method' do
        expect(client).to have_received(:confirm_sign_up).with(client_id: 'supersecretkey2', secret_hash: 'QGGa3OLislakJW63OXujsIzjOxqYgSxptyRHAuyobd8=', username: email, confirmation_code: confirmation_code)
      end
    end

    context 'when there are errors' do
      before do
        allow(client).to receive(:confirm_sign_up).and_raise(error.new('Some context', 'Some message'))
        confirm_sign_up.call
      end

      context 'and the error is generic' do
        let(:error) { Aws::CognitoIdentityProvider::Errors::ServiceError }

        it 'sets the error and success will be false' do
          expect(confirm_sign_up.errors[:confirmation_code].first).to eq 'Some message'
          expect(confirm_sign_up.success?).to be false
        end
      end

      context 'and the error is NotAuthorizedException' do
        let(:error) { Aws::CognitoIdentityProvider::Errors::NotAuthorizedException }

        it 'sets the error and success will be false' do
          expect(confirm_sign_up.errors[:confirmation_code].first).to eq 'Invalid verification code provided, please try again.'
          expect(confirm_sign_up.success?).to be false
        end
      end
    end
  end

  describe '.success?' do
    before { confirm_sign_up.valid? }

    context 'when there are no errors' do
      it 'returns true' do
        expect(confirm_sign_up.success?).to be true
      end
    end

    context 'when there are errors' do
      let(:confirmation_code) { '' }

      it 'returns false' do
        expect(confirm_sign_up.success?).to be false
      end
    end
  end
end

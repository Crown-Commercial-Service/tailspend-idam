require 'rails_helper'

RSpec.describe Cognito::ForgotPassword do
  let(:forgot_password) { described_class.new(email) }
  let(:email) { 'test@test.com' }

  describe 'validating the email' do
    context 'when the email is valid' do
      it 'is valid' do
        expect(forgot_password.valid?).to be true
      end
    end

    context 'and the domains contain a dash' do
      let(:email) { 'test@digital.cabinet-office.gov.uk' }

      it 'is valid' do
        expect(forgot_password.valid?).to be true
      end
    end

    context 'when calling the object' do
      before { forgot_password.call }

      context 'and the email is blank' do
        let(:email) { '' }

        it 'the call was not successfull' do
          expect(forgot_password.success?).to be false
        end

        it 'has the correct error message' do
          expect(forgot_password.errors[:email].first).to eq 'You must enter your email address in the correct format, like name@example.com'
        end
      end

      context 'and the email does not match the format' do
        let(:email) { 'this is not an email' }

        it 'the call was not successfull' do
          expect(forgot_password.success?).to be false
        end

        it 'has the correct error message' do
          expect(forgot_password.errors[:email].first).to eq 'You must enter your email address in the correct format, like name@example.com'
        end
      end
    end
  end

  describe 'initialisation of email' do
    let(:forgot_password) { described_class.new(email) }

    context 'when the email contains capital letters' do
      let(:email) { 'Test@TeST.com' }

      it 'becomes downcased when the object is initialised' do
        expect(forgot_password.email).to eq 'test@test.com'
      end
    end
  end

  describe 'call' do
    let(:client) { instance_double(Aws::CognitoIdentityProvider::Client) }

    before do
      stub_const('ENV', { 'COGNITO_AWS_REGION' => 'supersecretregion', 'COGNITO_CLIENT_SECRET' => 'supersecretkey1', 'COGNITO_CLIENT_ID' => 'supersecretkey2' })
      allow(Aws::CognitoIdentityProvider::Client).to receive(:new).with(region: 'supersecretregion').and_return(client)
    end

    context 'when everything is valid' do
      before do
        allow(client).to receive(:forgot_password)
        forgot_password.call
      end

      it 'calls forgot_password on client' do
        expect(client).to have_received(:forgot_password).with(client_id: 'supersecretkey2', secret_hash: 'QGGa3OLislakJW63OXujsIzjOxqYgSxptyRHAuyobd8=', username: email)
      end
    end

    context 'when an error occurs' do
      before do
        allow(client).to receive(:forgot_password).and_raise(error.new('Some context', 'Some message'))
        forgot_password.call
      end

      context 'and the error is UserNotFoundException' do
        let(:error) { Aws::CognitoIdentityProvider::Errors::UserNotFoundException }

        it 'does not set an error and success will be true' do
          expect(forgot_password.errors.none?).to be true
          expect(forgot_password.success?).to be true
        end
      end

      context 'and the error is InvalidParameterException' do
        let(:error) { Aws::CognitoIdentityProvider::Errors::InvalidParameterException }

        it 'sets the error and success will be false' do
          expect(forgot_password.errors[:base].first).to eq 'Please check the information you have entered'
          expect(forgot_password.success?).to be false
        end
      end

      context 'and the error is ServiceError' do
        let(:error) { Aws::CognitoIdentityProvider::Errors::ServiceError }

        it 'sets the error and success will be false' do
          expect(forgot_password.errors[:base].first).to eq 'Some message'
          expect(forgot_password.success?).to be false
        end
      end
    end
  end
end

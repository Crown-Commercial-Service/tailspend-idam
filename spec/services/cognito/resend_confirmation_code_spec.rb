require 'rails_helper'

RSpec.describe Cognito::ResendConfirmationCode do
  subject(:resend_confirmation_code) { described_class.new(email) }

  let(:email) { 'tester@test.com' }

  describe '.initialize' do
    context 'when the email is nil' do
      let(:email) { nil }

      it 'sets the email and error as nil' do
        expect(resend_confirmation_code.email).to be_nil
        expect(resend_confirmation_code.error).to be_nil
      end
    end

    context 'when the email contains uppercase letters' do
      let(:email) { 'Tester@Test.com' }

      it 'converts the email to lowercase and sets error as nil' do
        expect(resend_confirmation_code.email).to eq 'tester@test.com'
        expect(resend_confirmation_code.error).to be_nil
      end
    end

    context 'when the email contains all lowercase letters' do
      it 'sets the email unchanged and sets error as nil' do
        expect(resend_confirmation_code.email).to eq 'tester@test.com'
        expect(resend_confirmation_code.error).to be_nil
      end
    end
  end

  describe '.call' do
    let(:client) { instance_double(Aws::CognitoIdentityProvider::Client) }

    before do
      ENV['COGNITO_AWS_REGION'] = 'supersecretregion'
      ENV['COGNITO_CLIENT_SECRET'] = 'supersecretkey1'
      ENV['COGNITO_CLIENT_ID'] = 'supersecretkey2'
      allow(Aws::CognitoIdentityProvider::Client).to receive(:new).with(region: 'supersecretregion').and_return(client)
    end

    context 'when there are no errors' do
      before do
        allow(client).to receive(:resend_confirmation_code)
        resend_confirmation_code.call
      end

      it 'calls the method' do
        expect(client).to have_received(:resend_confirmation_code).with(client_id: 'supersecretkey2', secret_hash: 'AyQyqo5Ow7xTkXUCSAc01+Gp0O5t0jxD/z4qnkmTpWg=', username: email)
      end
    end

    context 'when there are errors' do
      before do
        allow(client).to receive(:resend_confirmation_code).and_raise(Aws::CognitoIdentityProvider::Errors::ServiceError.new('Some context', 'Some message'))
        resend_confirmation_code.call
      end

      it 'sets the error and success will be false' do
        expect(resend_confirmation_code.error).to eq 'Some message'
        expect(resend_confirmation_code.success?).to be false
      end
    end
  end

  describe '.success?' do
    context 'when the error is nil' do
      it 'returns true' do
        expect(resend_confirmation_code.success?).to be true
      end
    end

    context 'when the error is not nil' do
      before { resend_confirmation_code.error = 'I am Error' }

      it 'returns false' do
        expect(resend_confirmation_code.success?).to be false
      end
    end
  end
end

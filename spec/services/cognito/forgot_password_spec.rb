require 'rails_helper'

RSpec.describe Cognito::ForgotPassword do
  describe 'validating the email' do
    let(:forgot_password) { described_class.new(email) }
    let(:email) { 'test@test.com' }

    context 'when the email is valid' do
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
          expect(forgot_password.error).to eq 'You must enter your email address in the correct format, like name@example.com'
        end
      end

      context 'and the email does not match the format' do
        let(:email) { 'this is not an email' }

        it 'the call was not successfull' do
          expect(forgot_password.success?).to be false
        end

        it 'has the correct error message' do
          expect(forgot_password.error).to eq 'You must enter your email address in the correct format, like name@example.com'
        end
      end
    end
  end
end

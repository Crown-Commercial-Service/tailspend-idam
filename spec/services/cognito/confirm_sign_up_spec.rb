require 'rails_helper'

RSpec.describe Cognito::ConfirmSignUp do
  let(:confirm_sign_up) { described_class.new(params) }

  let(:params) do
    {
      email: email,
      confirmation_code: confirmation_code
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

      it 'will become downcased when the object is initialised' do
        expect(confirm_sign_up.email).to eq 'test@test.com'
      end
    end
  end
end

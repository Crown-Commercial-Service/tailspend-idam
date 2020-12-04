require 'rails_helper'

RSpec.describe Cognito::SignInUser do
  describe '.valid?' do
    let(:sign_in_user) { described_class.new(email, password, nil, false) }
    let(:email) { 'test@test.com' }
    let(:password) { 'password123!' }

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
    let(:sign_in_user) { described_class.new(email, '', nil, false) }

    context 'when the email contains capital letters' do
      let(:email) { 'Test@TeST.com' }

      it 'will become downcased when the object is initialised' do
        expect(sign_in_user.email).to eq 'test@test.com'
      end
    end
  end
end

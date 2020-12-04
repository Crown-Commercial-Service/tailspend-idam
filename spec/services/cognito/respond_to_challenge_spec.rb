require 'rails_helper'

RSpec.describe Cognito::RespondToChallenge do
  let(:respond_to_challenge) { described_class.new(challeng_name, '123456', 1, options) }

  describe '.valid? for new passowrd required' do
    let(:challeng_name) { 'NEW_PASSWORD_REQUIRED' }
    let(:options) { { new_password: new_password, new_password_confirmation: new_password_confirmation } }
    let(:new_password) { 'Test12345!' }
    let(:new_password_confirmation) { new_password }
    let(:valid_symbols_sample) { '=+-^$*.[]{}()?"!@#%&/\\,><\':;|_~`'.split('').sample(6).join }
    let(:invalid_symbols_sample) { 'ĀĘÌÕŪŸ'.split('').sample(2).join }

    context 'when all attributes are valid' do
      it 'is valid' do
        expect(respond_to_challenge.valid?).to be true
      end
    end

    context 'when considering the new_password' do
      context 'and it is blank' do
        let(:new_password) { '' }

        it 'is not valid' do
          expect(respond_to_challenge.valid?).to be false
        end

        it 'has the correct error message' do
          respond_to_challenge.valid?
          expect(respond_to_challenge.errors[:new_password].first).to eq 'Enter a password'
        end
      end

      context 'and it does not contain a capital letter' do
        let(:new_password) { 'password123!' }

        it 'is not valid' do
          expect(respond_to_challenge.valid?).to be false
        end

        it 'has the correct error message' do
          respond_to_challenge.valid?
          expect(respond_to_challenge.errors[:new_password].first).to eq 'Password must include a capital letter'
        end
      end

      context 'and it does not contain a number' do
        let(:new_password) { 'PasswordOne!' }

        it 'is not valid' do
          expect(respond_to_challenge.valid?).to be false
        end

        it 'has the correct error message' do
          respond_to_challenge.valid?
          expect(respond_to_challenge.errors[:new_password].first).to eq 'Password must include a number'
        end
      end

      context 'and it does not contain a symbol' do
        let(:new_password) { 'Password1234' }

        it 'is valid' do
          expect(respond_to_challenge.valid?).to be true
        end
      end

      context 'and it cointains valid symbols' do
        let(:new_password) { ("Password1234#{valid_symbols_sample}").split('').shuffle.join }

        it 'is valid' do
          expect(respond_to_challenge.valid?).to be true
        end
      end

      context 'and it contains 1 invalid symbol' do
        let(:new_password) { ("Password1234#{valid_symbols_sample}#{invalid_symbols_sample[0]}").split('').shuffle.join }

        it 'is not valid' do
          expect(respond_to_challenge.valid?).to be false
        end

        it 'has the correct error message' do
          respond_to_challenge.valid?
          expect(respond_to_challenge.errors[:new_password].first).to eq 'Your password includes invalid symbols'
        end
      end

      context 'and it contains multiple invalid symbols' do
        let(:new_password) { ("Password1234#{valid_symbols_sample}#{invalid_symbols_sample}").split('').shuffle.join }

        it 'is not valid' do
          expect(respond_to_challenge.valid?).to be false
        end

        it 'has the correct error message' do
          respond_to_challenge.valid?
          expect(respond_to_challenge.errors[:new_password].first).to eq 'Your password includes invalid symbols'
        end
      end

      context 'and it is too short' do
        let(:new_password) { 'Po123!' }

        it 'is not valid' do
          expect(respond_to_challenge.valid?).to be false
        end

        it 'has the correct error message' do
          respond_to_challenge.valid?
          expect(respond_to_challenge.errors[:new_password].first).to eq 'The password you entered is not long enough, it needs to be at least 10 characters long'
        end
      end
    end

    context 'when considering the password_confirmation' do
      context 'and it is blank while the password is blank' do
        let(:new_password) { '' }
        let(:new_password_confirmation) { '' }

        it 'is not valid' do
          expect(respond_to_challenge.valid?).to be false
        end

        it 'has the correct error message' do
          respond_to_challenge.valid?
          expect(respond_to_challenge.errors[:new_password_confirmation].first).to eq 'Enter your confirmation password'
        end
      end

      context 'and it is blank while the password is present' do
        let(:new_password_confirmation) { '' }

        it 'is not valid' do
          expect(respond_to_challenge.valid?).to be false
        end

        it 'has the correct error message' do
          respond_to_challenge.valid?
          expect(respond_to_challenge.errors[:new_password_confirmation].first).to eq 'Enter your confirmation password'
        end
      end

      context 'and it does not match the password' do
        let(:new_password_confirmation) { 'Password124!' }

        it 'is not valid' do
          expect(respond_to_challenge.valid?).to be false
        end

        it 'has the correct error message' do
          respond_to_challenge.valid?
          expect(respond_to_challenge.errors[:new_password_confirmation].first).to eq 'Passwords don\'t match'
        end
      end
    end
  end

  describe '.valid? for sms mfa' do
    let(:challeng_name) { 'SMS_MFA' }
    let(:options) { { access_code: access_code } }
    let(:access_code) { '123456' }

    context 'when all attributes are valid' do
      it 'is valid' do
        expect(respond_to_challenge.valid?).to be true
      end
    end

    context 'when considering the access_code' do
      context 'and it is blank' do
        let(:access_code) { '' }

        it 'is not valid' do
          expect(respond_to_challenge.valid?).to be false
        end

        it 'has the correct error message' do
          respond_to_challenge.valid?
          expect(respond_to_challenge.errors[:access_code].first).to eq 'Enter the access code'
        end
      end

      context 'and it does not match the format' do
        let(:access_code) { '01234S' }

        it 'is not valid' do
          expect(respond_to_challenge.valid?).to be false
        end

        it 'has the correct error message' do
          respond_to_challenge.valid?
          expect(respond_to_challenge.errors[:access_code].first).to eq 'Access code must contain numeric characters only'
        end
      end

      context 'and it is too short' do
        let(:access_code) { '123' }

        it 'is not valid' do
          expect(respond_to_challenge.valid?).to be false
        end

        it 'has the correct error message' do
          respond_to_challenge.valid?
          expect(respond_to_challenge.errors[:access_code].first).to eq 'Access code must be 6 characters'
        end
      end

      context 'and it is too long' do
        let(:access_code) { '1234567' }

        it 'is not valid' do
          expect(respond_to_challenge.valid?).to be false
        end

        it 'has the correct error message' do
          respond_to_challenge.valid?
          expect(respond_to_challenge.errors[:access_code].first).to eq 'Access code must be 6 characters'
        end
      end
    end
  end
end

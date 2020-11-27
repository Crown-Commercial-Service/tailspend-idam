require 'rails_helper'

RSpec.describe Cognito::ConfirmPasswordReset do
  describe '.valid?' do
    let(:confirm_password_reset) { described_class.new('test@test.com', password, password_confirmation, confirmation_code) }
    let(:password) { 'Password123!' }
    let(:password_confirmation) { password }
    let(:confirmation_code) { '123456' }
    let(:valid_symbols_sample) { '=+-^$*.[]{}()?"!@#%&/\\,><\':;|_~`'.split('').sample(5).join }
    let(:invalid_symbols_sample) { '£èöíäü'.split('').sample(2).join }

    context 'when all attributes are valid' do
      it 'is valid' do
        expect(confirm_password_reset.valid?).to be true
      end
    end

    context 'when considering the password' do
      context 'and it is blank' do
        let(:password) { '' }

        it 'is not valid' do
          expect(confirm_password_reset.valid?).to be false
        end

        it 'has the correct error message' do
          confirm_password_reset.valid?
          expect(confirm_password_reset.errors[:password].first).to eq 'Enter a password'
        end
      end

      context 'and it does not contain a capital letter' do
        let(:password) { 'password123!' }

        it 'is not valid' do
          expect(confirm_password_reset.valid?).to be false
        end

        it 'has the correct error message' do
          confirm_password_reset.valid?
          expect(confirm_password_reset.errors[:password].first).to eq 'Password must include a capital letter'
        end
      end

      context 'and it does not contain a number' do
        let(:password) { 'PasswordOne!' }

        it 'is not valid' do
          expect(confirm_password_reset.valid?).to be false
        end

        it 'has the correct error message' do
          confirm_password_reset.valid?
          expect(confirm_password_reset.errors[:password].first).to eq 'Password must include a number'
        end
      end

      context 'and it does not contain a symbol' do
        let(:password) { 'Password1234' }

        it 'is valid' do
          expect(confirm_password_reset.valid?).to be true
        end
      end

      context 'and it cointains valid symbols' do
        let(:password) { ("Password1234#{valid_symbols_sample}").split('').shuffle.join }

        it 'is valid' do
          expect(confirm_password_reset.valid?).to be true
        end
      end

      context 'and it contains 1 invalid symbol' do
        let(:password) { ("Password1234#{valid_symbols_sample}#{invalid_symbols_sample[0]}").split('').shuffle.join }

        it 'is not valid' do
          expect(confirm_password_reset.valid?).to be false
        end

        it 'has the correct error message' do
          confirm_password_reset.valid?
          expect(confirm_password_reset.errors[:password].first).to eq 'Your password includes invalid symbols'
        end
      end

      context 'and it contains multiple invalid symbols' do
        let(:password) { ("Password1234#{valid_symbols_sample}#{invalid_symbols_sample}").split('').shuffle.join }

        it 'is not valid' do
          expect(confirm_password_reset.valid?).to be false
        end

        it 'has the correct error message' do
          confirm_password_reset.valid?
          expect(confirm_password_reset.errors[:password].first).to eq 'Your password includes invalid symbols'
        end
      end

      context 'and it is too short' do
        let(:password) { 'Po123!' }

        it 'is not valid' do
          expect(confirm_password_reset.valid?).to be false
        end

        it 'has the correct error message' do
          confirm_password_reset.valid?
          expect(confirm_password_reset.errors[:password].first).to eq 'The password you entered is not long enough, it needs to be at least 10 characters long'
        end
      end
    end

    context 'when considering the password_confirmation' do
      context 'and it is blank while the password is blank' do
        let(:password) { '' }
        let(:password_confirmation) { '' }

        it 'is not valid' do
          expect(confirm_password_reset.valid?).to be false
        end

        it 'has the correct error message' do
          confirm_password_reset.valid?
          expect(confirm_password_reset.errors[:password_confirmation].first).to eq 'Enter your confirmation password'
        end
      end

      context 'and it is blank while the password is present' do
        let(:password_confirmation) { '' }

        it 'is not valid' do
          expect(confirm_password_reset.valid?).to be false
        end

        it 'has the correct error message' do
          confirm_password_reset.valid?
          expect(confirm_password_reset.errors[:password_confirmation].first).to eq 'Enter your confirmation password'
        end
      end

      context 'and it does not match the password' do
        let(:password_confirmation) { 'Password124!' }

        it 'is not valid' do
          expect(confirm_password_reset.valid?).to be false
        end

        it 'has the correct error message' do
          confirm_password_reset.valid?
          expect(confirm_password_reset.errors[:password_confirmation].first).to eq 'Passwords don\'t match'
        end
      end
    end

    context 'when considering the confirmation_code' do
      context 'and it is blank' do
        let(:confirmation_code) { '' }

        it 'is not valid' do
          expect(confirm_password_reset.valid?).to be false
        end

        it 'has the correct error message' do
          confirm_password_reset.valid?
          expect(confirm_password_reset.errors[:confirmation_code].first).to eq 'Enter your verification code'
        end
      end
    end
  end
end

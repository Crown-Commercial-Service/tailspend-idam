require 'rails_helper'

RSpec.describe Cognito::SignUpUser do
  describe '.valid?' do
    let(:sign_up_user) { described_class.new(email, password, password_confirmation, organisation, first_name, last_name) }
    let(:email) { 'test@test.com' }
    let(:password) { 'Password123!' }
    let(:password_confirmation) { password }
    let(:organisation) { 'Crown Commercial Serice' }
    let(:first_name) { 'John' }
    let(:last_name) { 'Smith' }
    let(:domain) { 'test.com' }

    before { DomainsWhiteList.create(url: domain, active: true) }

    context 'when all attributes are valid' do
      it 'is valid' do
        expect(sign_up_user.valid?).to be true
      end
    end

    context 'when considering the email' do
      context 'and it is blank' do
        let(:email) { '' }

        it 'is not valid' do
          expect(sign_up_user.valid?).to be false
        end

        it 'has the correct error message' do
          sign_up_user.valid?
          expect(sign_up_user.errors[:email].first).to eq 'Enter an email address in the correct format, like name@example.com'
        end
      end

      context 'and it is not on the domain whitelist' do
        let(:domain) { 'toast.com' }

        it 'is not valid' do
          expect(sign_up_user.valid?).to be false
        end

        it 'has the correct error message' do
          sign_up_user.valid?
          expect(sign_up_user.errors[:email].first).to eq 'You must use a public sector email'
        end
      end
    end

    context 'when considering the organisation' do
      context 'and it is blank' do
        let(:organisation) { '' }

        it 'is not valid' do
          expect(sign_up_user.valid?).to be false
        end

        it 'has the correct error message' do
          sign_up_user.valid?
          expect(sign_up_user.errors[:organisation].first).to eq 'Enter your organisation'
        end
      end
    end

    context 'when considering the first_name' do
      context 'and it is blank' do
        let(:first_name) { '' }

        it 'is not valid' do
          expect(sign_up_user.valid?).to be false
        end

        it 'has the correct error message' do
          sign_up_user.valid?
          expect(sign_up_user.errors[:first_name].first).to eq 'Enter your first name'
        end
      end

      context 'and it is too short' do
        let(:first_name) { 'J' }

        it 'is not valid' do
          expect(sign_up_user.valid?).to be false
        end

        it 'has the correct error message' do
          sign_up_user.valid?
          expect(sign_up_user.errors[:first_name].first).to eq 'First name must be 2 characters or more'
        end
      end
    end

    context 'when considering the last_name' do
      context 'and it is blank' do
        let(:last_name) { '' }

        it 'is not valid' do
          expect(sign_up_user.valid?).to be false
        end

        it 'has the correct error message' do
          sign_up_user.valid?
          expect(sign_up_user.errors[:last_name].first).to eq 'Enter your last name'
        end
      end

      context 'and it is too short' do
        let(:last_name) { 'S' }

        it 'is not valid' do
          expect(sign_up_user.valid?).to be false
        end

        it 'has the correct error message' do
          sign_up_user.valid?
          expect(sign_up_user.errors[:last_name].first).to eq 'Last name must be 2 characters or more'
        end
      end
    end

    context 'when considering the password' do
      context 'and it is blank' do
        let(:password) { '' }

        it 'is not valid' do
          expect(sign_up_user.valid?).to be false
        end

        it 'has the correct error message' do
          sign_up_user.valid?
          expect(sign_up_user.errors[:password].first).to eq 'Enter a password'
        end
      end

      context 'and it does not contain a capital letter' do
        let(:password) { 'password123!' }

        it 'is not valid' do
          expect(sign_up_user.valid?).to be false
        end

        it 'has the correct error message' do
          sign_up_user.valid?
          expect(sign_up_user.errors[:password].first).to eq 'Password must include a capital letter'
        end
      end

      context 'and it does not contain a number' do
        let(:password) { 'PasswordOne!' }

        it 'is not valid' do
          expect(sign_up_user.valid?).to be false
        end

        it 'has the correct error message' do
          sign_up_user.valid?
          expect(sign_up_user.errors[:password].first).to eq 'Password must include a number'
        end
      end

      context 'and it does not contain a symbol' do
        let(:password) { 'Password1234' }

        it 'is not valid' do
          expect(sign_up_user.valid?).to be false
        end

        it 'has the correct error message' do
          sign_up_user.valid?
          expect(sign_up_user.errors[:password].first).to eq 'Password must include a symbol (for example ? ! & %)'
        end
      end

      context 'and it is too short' do
        let(:password) { 'Po123!' }

        it 'is not valid' do
          expect(sign_up_user.valid?).to be false
        end

        it 'has the correct error message' do
          sign_up_user.valid?
          expect(sign_up_user.errors[:password].first).to eq 'The password you entered is not long enough, it needs to be at least 10 characters long'
        end
      end
    end

    context 'when considering the password_confirmation' do
      context 'and it is blank' do
        let(:password) { '' }

        it 'is not valid' do
          expect(sign_up_user.valid?).to be false
        end

        it 'has the correct error message' do
          sign_up_user.valid?
          expect(sign_up_user.errors[:password_confirmation].first).to eq 'Enter your confirm password'
        end
      end

      context 'and it does not match the password' do
        let(:password_confirmation) { 'Password124!' }

        it 'is not valid' do
          expect(sign_up_user.valid?).to be false
        end

        it 'has the correct error message' do
          sign_up_user.valid?
          expect(sign_up_user.errors[:password_confirmation].first).to eq 'Passwords don\'t match'
        end
      end
    end
  end
end

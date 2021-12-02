require 'rails_helper'

RSpec.describe Cognito::SignUpUser do
  let(:sign_up_user) { described_class.new(params) }

  let(:params) do
    { email: email,
      password: password,
      password_confirmation: password_confirmation,
      summary_line: summary_line,
      first_name: first_name,
      last_name: last_name }
  end

  let(:email) { 'test@test.com' }
  let(:password) { 'Password123!' }
  let(:password_confirmation) { password }
  let(:summary_line) { 'Active Organisation 69 (69 Test Road, Norwich, AB1 2CD)' }
  let(:first_name) { 'John' }
  let(:last_name) { 'Smith' }
  let(:domain) { 'test.com' }

  describe '.valid?' do
    let(:valid_symbols_sample) { '=+-^$*.[]{}()?"!@#%&/\\,><\':;|_~`'.split('').sample(7).join }
    let(:invalid_symbols_sample) { 'èÿüíōæß'.split('').sample(3).join }

    before { AllowedEmailDomain.create(url: domain, active: true) }

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

      context 'and it is not on the allow list' do
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

    context 'when considering the summary_line' do
      context 'and it is blank' do
        let(:summary_line) { '' }

        before { sign_up_user.valid? }

        it 'is not valid' do
          expect(sign_up_user.valid?).to be false
        end

        it 'has the correct error message' do
          expect(sign_up_user.errors[:summary_line].first).to eq 'Enter your organisation'
        end

        it 'does not add an error of type not_found' do
          expect(sign_up_user.errors.of_kind?(:summary_line, :not_found)).to be false
        end
      end

      context 'and it belongs to an organisation that does not exist' do
        let(:summary_line) { 'My Fake Organisation' }

        before { sign_up_user.valid? }

        it 'has the correct error message' do
          expect(sign_up_user.errors[:summary_line].first).to eq 'A public sector organisation with the name you entered could not be found'
        end

        it 'does add an error of type not_found' do
          expect(sign_up_user.errors.of_kind?(:summary_line, :not_found)).to be true
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

        it 'is valid' do
          expect(sign_up_user.valid?).to be true
        end
      end

      context 'and it cointains valid symbols' do
        let(:password) { ("Password1234#{valid_symbols_sample}").split('').shuffle.join }

        it 'is valid' do
          expect(sign_up_user.valid?).to be true
        end
      end

      context 'and it contains 1 invalid symbol' do
        let(:password) { ("Password1234#{valid_symbols_sample}#{invalid_symbols_sample[0]}").split('').shuffle.join }

        it 'is not valid' do
          expect(sign_up_user.valid?).to be false
        end

        it 'has the correct error message' do
          sign_up_user.valid?
          expect(sign_up_user.errors[:password].first).to eq 'Your password includes invalid symbols'
        end
      end

      context 'and it contains multiple invalid symbols' do
        let(:password) { ("Password1234#{valid_symbols_sample}#{invalid_symbols_sample}").split('').shuffle.join }

        it 'is not valid' do
          expect(sign_up_user.valid?).to be false
        end

        it 'has the correct error message' do
          sign_up_user.valid?
          expect(sign_up_user.errors[:password].first).to eq 'Your password includes invalid symbols'
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
          expect(sign_up_user.errors[:password_confirmation].first).to eq 'Enter your confirmation password'
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

  describe 'initialisation of email' do
    context 'when the email contains capital letters' do
      let(:email) { 'Test@TeST.com' }

      it 'will become downcased when the object is initialised' do
        expect(sign_up_user.email).to eq 'test@test.com'
      end
    end
  end
end

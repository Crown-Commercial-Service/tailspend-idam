require 'rails_helper'

RSpec.describe Cognito::ConfirmPasswordReset do
  let(:confirm_password_reset) { described_class.new(params) }

  let(:params) do
    {
      email:,
      password:,
      password_confirmation:,
      confirmation_code:
    }
  end

  let(:email) { 'test@test.com' }
  let(:password) { 'Password123!' }
  let(:password_confirmation) { password }
  let(:confirmation_code) { '123456' }

  describe '.valid?' do
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
        %w[= + - ^ $ * . [ ] { } ( ) ? " ! @ # % & / \ , > < ' : ; | _ ~ `].each do |symbol|
          let(:password) do
            allowed_characters = ALLOWED_CHARACTERS.dup
            allowed_characters[-1] = [symbol]
            generate_random_password(allowed_characters)
          end

          it "is valid when the symbol is #{symbol}" do
            expect(confirm_password_reset.valid?).to be true
          end
        end
      end

      context 'and it contains invalid symbols' do
        let(:password) { generate_random_invalid_password }

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

      context 'and it has been pwned' do
        let(:password) { PwnedPassword.pluck(:password).sample }

        it 'is not valid' do
          expect(confirm_password_reset.valid?).to be false
        end

        it 'has the correct error message' do
          confirm_password_reset.valid?
          expect(confirm_password_reset.errors[:password].first).to eq 'Enter a password that is harder to guess'
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

  describe 'initialisation of email' do
    context 'when the email contains capital letters' do
      let(:email) { 'Test@TeST.com' }

      it 'will become downcased when the object is initialised' do
        expect(confirm_password_reset.email).to eq 'test@test.com'
      end
    end
  end

  describe '.call' do
    let(:client) { instance_double(Aws::CognitoIdentityProvider::Client) }
    let(:cognito_user) { double }
    let(:attribute_type) { double }

    before do
      stub_const('ENV', { 'COGNITO_AWS_REGION' => 'supersecretregion', 'COGNITO_CLIENT_SECRET' => 'supersecretkey1', 'COGNITO_CLIENT_ID' => 'supersecretkey2' })
      allow(Aws::CognitoIdentityProvider::Client).to receive(:new).with(region: 'supersecretregion').and_return(client)
      allow(client).to receive(:admin_get_user).and_return(cognito_user)
      allow(cognito_user).to receive(:user_attributes).and_return([attribute_type])
      allow(attribute_type).to receive_messages(name: 'sub', value: 'my-cognito-id')
      allow(client).to receive(:admin_list_groups_for_user)
    end

    context 'when everything is valid' do
      context 'and confirm_forgot_password does not raise an error' do
        before do
          allow(client).to receive(:confirm_forgot_password)
          confirm_password_reset.call
        end

        it 'calls confirm_forgot_password' do
          expect(client).to have_received(:confirm_forgot_password).with(client_id: 'supersecretkey2', secret_hash: 'QGGa3OLislakJW63OXujsIzjOxqYgSxptyRHAuyobd8=', username: email, password: password, confirmation_code: confirmation_code)
        end
      end

      context 'and confirm_forgot_password rasies CodeMismatchException' do
        before do
          allow(client).to receive(:confirm_forgot_password).and_raise(Aws::CognitoIdentityProvider::Errors::CodeMismatchException.new('Some context', 'Some message'))
          confirm_password_reset.call
        end

        it 'adds the error' do
          expect(confirm_password_reset.errors[:confirmation_code].first).to eq 'Some message'
        end
      end

      context 'and confirm_forgot_password rasies ServiceError' do
        before do
          allow(client).to receive(:confirm_forgot_password).and_raise(Aws::CognitoIdentityProvider::Errors::ServiceError.new('Some context', 'Some message'))
          confirm_password_reset.call
        end

        it 'adds the error' do
          expect(confirm_password_reset.errors[:base].first).to eq 'Some message'
        end
      end

      context 'when the user can not be found' do
        let(:resp) { instance_double(Cognito::CreateUserFromCognito) }

        before do
          allow(client).to receive(:confirm_forgot_password)
          allow(Cognito::CreateUserFromCognito).to receive(:call).with(email).and_return(resp)
          allow(resp).to receive(:success?).and_return(false)
          confirm_password_reset.call
        end

        it 'adds the user can not be found error' do
          expect(confirm_password_reset.errors[:base].first).to eq 'Please check the information you have entered'
        end
      end
    end

    context 'when somthing is not valid' do
      let(:password_confirmation) { 'Samus' }

      before do
        allow(confirm_password_reset).to receive(:confirm_forgot_password)
        allow(confirm_password_reset).to receive(:create_user_if_needed)
      end

      it 'does not call confirm_forgot_password or create_user_if_needed' do
        expect(confirm_password_reset).not_to have_received(:confirm_forgot_password)
        expect(confirm_password_reset).not_to have_received(:create_user_if_needed)
      end
    end
  end

  describe '.success?' do
    before { confirm_password_reset.valid? }

    context 'when there are no errors' do
      it 'returns true' do
        expect(confirm_password_reset.success?).to be true
      end
    end

    context 'when there are errors' do
      let(:confirmation_code) { '' }

      it 'returns false' do
        expect(confirm_password_reset.success?).to be false
      end
    end
  end
end

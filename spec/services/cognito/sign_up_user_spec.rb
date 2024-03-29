require 'rails_helper'

RSpec.describe Cognito::SignUpUser do
  let(:sign_up_user) { described_class.new(params) }

  let(:params) do
    { email:,
      password:,
      password_confirmation:,
      summary_line:,
      first_name:,
      last_name: }
  end

  let(:email) { 'test@test.com' }
  let(:password) { 'Password123!' }
  let(:password_confirmation) { password }
  let(:summary_line) { 'Active Organisation 69 (69 Test Road, Norwich, AB1 2CD)' }
  let(:first_name) { 'John' }
  let(:last_name) { 'Smith' }
  let(:domain) { 'test.com' }

  before { AllowedEmailDomain.create(url: domain, active: true) }

  describe '.valid?' do
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
          expect(sign_up_user.errors[:email].first).to eq 'You must enter your email address in the correct format, like name@example.com'
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

      context 'and it is not in the correct format' do
        let(:email) { 'Elma' }

        it 'is not valid' do
          expect(sign_up_user.valid?).to be false
        end

        it 'has the correct error message' do
          sign_up_user.valid?
          expect(sign_up_user.errors[:email].first).to eq 'You must enter your email address in the correct format, like name@example.com'
        end
      end

      context 'and the domains contain a dash' do
        let(:email) { 'elma@blade.xenoblade-x.ca.us' }
        let(:domain) { 'blade.xenoblade-x.ca.us' }

        it 'is valid' do
          expect(sign_up_user.valid?).to be true
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
        %w[= + - ^ $ * . [ ] { } ( ) ? " ! @ # % & / \ , > < ' : ; | _ ~ `].each do |symbol|
          let(:password) do
            allowed_characters = ALLOWED_CHARACTERS.dup
            allowed_characters[-1] = [symbol]
            generate_random_password(allowed_characters)
          end

          it "is valid when the symbol is #{symbol}" do
            expect(sign_up_user.valid?).to be true
          end
        end
      end

      context 'and it contains invalid symbols' do
        let(:password) { generate_random_invalid_password }

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

      context 'and it has been pwned' do
        let(:password) { PwnedPassword.pluck(:password).sample }

        it 'is not valid' do
          expect(sign_up_user.valid?).to be false
        end

        it 'has the correct error message' do
          sign_up_user.valid?
          expect(sign_up_user.errors[:password].first).to eq 'Enter a password that is harder to guess'
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

      it 'becomes downcased when the object is initialised' do
        expect(sign_up_user.email).to eq 'test@test.com'
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

    context 'when it is valid' do
      let(:response) { double }

      before do
        allow(client).to receive(:sign_up).and_return(response)
        allow(response).to receive(:[]).with('user_sub').and_return('123456')
        sign_up_user.call
      end

      it 'calls sign_up on client' do
        expect(client).to have_received(:sign_up).with(client_id: 'supersecretkey2',
                                                       secret_hash: 'QGGa3OLislakJW63OXujsIzjOxqYgSxptyRHAuyobd8=',
                                                       username: email,
                                                       password: password,
                                                       user_attributes: [{ name: 'email', value: email },
                                                                         { name: 'name', value: first_name },
                                                                         { name: 'family_name', value: last_name },
                                                                         { name: 'custom:organisation_name', value: 'Active Organisation 69' },
                                                                         { name: 'phone_number', value: '+4408654876588' }])
      end
    end

    context 'when an error is raised' do
      before do
        allow(client).to receive(:sign_up).and_raise(error.new('Some context', 'Some message'))
        sign_up_user.call
      end

      context 'and the error is generic' do
        let(:error) { Aws::CognitoIdentityProvider::Errors::ServiceError }

        it 'sets the error and success will be false' do
          expect(sign_up_user.errors[:base].first).to eq 'Some message'
          expect(sign_up_user.success?).to be false
        end
      end

      context 'and the error is UsernameExistsException' do
        let(:error) { Aws::CognitoIdentityProvider::Errors::UsernameExistsException }

        it 'success will be true' do
          expect(sign_up_user.success?).to be true
        end
      end
    end
  end

  describe '.success?' do
    before { sign_up_user.valid? }

    context 'when there are no errors' do
      it 'returns true' do
        expect(sign_up_user.success?).to be true
      end
    end

    context 'when there are errors' do
      let(:password_confirmation) { '' }

      it 'returns false' do
        expect(sign_up_user.success?).to be false
      end
    end
  end
end

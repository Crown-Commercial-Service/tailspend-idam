require 'rails_helper'

RSpec.describe Cognito::CreateUserFromCognito do
  subject(:create_user_from_cognito) { described_class.new(email) }

  let(:email) { 'tester@test.com' }

  describe '.initialize' do
    context 'when the email is nil' do
      let(:email) { nil }

      it 'sets the email and error as nil' do
        expect(create_user_from_cognito.email).to be_nil
        expect(create_user_from_cognito.error).to be_nil
      end
    end

    context 'when the email contains uppercase letters' do
      let(:email) { 'Tester@Test.com' }

      it 'converts the email to lowercase and sets error as nil' do
        expect(create_user_from_cognito.email).to eq 'tester@test.com'
        expect(create_user_from_cognito.error).to be_nil
      end
    end

    context 'when the email contains all lowercase letters' do
      it 'sets the email unchanged and sets error as nil' do
        expect(create_user_from_cognito.email).to eq 'tester@test.com'
        expect(create_user_from_cognito.error).to be_nil
      end
    end
  end

  describe 'call' do
    let(:client) { instance_double(Aws::CognitoIdentityProvider::Client) }

    before do
      ENV['COGNITO_AWS_REGION'] = 'supersecretregion'
      ENV['COGNITO_CLIENT_SECRET'] = 'supersecretkey1'
      ENV['COGNITO_CLIENT_ID'] = 'supersecretkey2'
      ENV['COGNITO_USER_POOL_ID'] = 'myuserpool'
      allow(Aws::CognitoIdentityProvider::Client).to receive(:new).with(region: 'supersecretregion').and_return(client)
    end

    context 'when everything is valid' do
      let(:cognito_user) { double }
      let(:attribute_type) { double }

      before do
        allow(client).to receive(:admin_get_user).and_return(cognito_user)
        allow(cognito_user).to receive(:user_attributes).and_return([attribute_type])
        allow(attribute_type).to receive_messages(name: 'sub', value: 'my-cognito-id')
        allow(client).to receive(:admin_list_groups_for_user)
        create_user_from_cognito.call
      end

      it 'calls the relvent methods' do
        expect(client).to have_received(:admin_get_user).with(user_pool_id: 'myuserpool', username: email)
        expect(client).to have_received(:admin_list_groups_for_user).with(user_pool_id: 'myuserpool', username: 'my-cognito-id')
      end
    end

    context 'when an error is raised' do
      before do
        allow(client).to receive(:admin_get_user).and_raise(Aws::CognitoIdentityProvider::Errors::ServiceError.new('Some context', 'Some message'))
        create_user_from_cognito.call
      end

      it 'sets the error and success will be false' do
        expect(create_user_from_cognito.error).to eq 'Some message'
        expect(create_user_from_cognito.success?).to be false
      end
    end
  end

  describe '.success?' do
    context 'when the error is nil' do
      it 'returns true' do
        expect(create_user_from_cognito.success?).to be true
      end
    end

    context 'when the error is not nil' do
      before { create_user_from_cognito.error = 'I am Error' }

      it 'returns false' do
        expect(create_user_from_cognito.success?).to be false
      end
    end
  end

  describe '.cognito_attribute' do
    let(:cognito_user) { double }
    let(:attribute_type) { double }

    before do
      create_user_from_cognito.instance_variable_set(:@cognito_user, cognito_user)
      allow(attribute_type).to receive_messages(name: 'sub', value: 'my-cognito-id')
    end

    context 'when the user has been found' do
      before { allow(cognito_user).to receive(:user_attributes).and_return([attribute_type]) }

      it 'returns the user ID' do
        expect(create_user_from_cognito.send(:cognito_attribute, 'sub')).to eq 'my-cognito-id'
      end
    end

    context 'when the user has not been found' do
      before { allow(cognito_user).to receive(:user_attributes).and_return([]) }

      it 'returns nil' do
        expect(create_user_from_cognito.send(:cognito_attribute, 'sub')).to be_nil
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Cognito::Common do
  describe 'building the secret hash' do
    let(:cognito_client_secret) { 'supersecretkey1' }
    let(:cognito_client_id) { 'supersecretkey2' }

    context 'when the params come from the environment variables' do
      let(:result) { described_class.build_secret_hash('tester@test.com') }

      before do
        stub_const('ENV', { 'COGNITO_CLIENT_SECRET' => cognito_client_secret, 'COGNITO_CLIENT_ID' => cognito_client_id })
      end

      it 'creates the same secret hash every time' do
        expect(result).to eq 'AyQyqo5Ow7xTkXUCSAc01+Gp0O5t0jxD/z4qnkmTpWg='
      end
    end

    context 'when the params are passed in' do
      let(:result) { described_class.build_client_secret_hash('tester@test.com', cognito_client_id, cognito_client_secret) }

      it 'creates the same secret hash every time' do
        expect(result).to eq 'AyQyqo5Ow7xTkXUCSAc01+Gp0O5t0jxD/z4qnkmTpWg='
      end
    end
  end

  describe 'bearer_token' do
    let(:request) { double }

    before { allow(request).to receive(:headers).and_return({ 'Authorization' => bearer_token }) }

    context 'when the bearer_token is present' do
      let(:bearer_token) { 'Bearer i-am-the-bearer-token' }

      it 'returns the token' do
        expect(described_class.bearer_token(request)).to eq 'i-am-the-bearer-token'
      end
    end

    context 'when the bearer_token is not present' do
      let(:bearer_token) { 'Some other token' }

      it 'returns nil' do
        expect(described_class.bearer_token(request)).to be_nil
      end
    end
  end
end

require 'rails_helper'

RSpec.describe TextEncryptor do
  let(:email) { 'test@email.com' }

  describe '.encrypt' do
    it 'successfully encrypts an email address' do
      expect(described_class.encrypt(email)).not_to include email
    end
  end

  describe '.decrypt' do
    let(:encrypted_email) { described_class.encrypt(email) }

    it 'successfully decrypts an encrypted email address' do
      expect(described_class.decrypt(encrypted_email)).to eq email
    end
  end
end

require 'rails_helper'

RSpec.describe PwnedPassword do
  describe 'password_pwned?' do
    context 'when the password has been pwned' do
      let(:pwned_passwords) { ['Password12345!', 'Password54321!', '!qwerTyuiop!96', 'asd12%fgHjkl76'] }

      it 'returns true for all the pawned passwords' do
        results = pwned_passwords.map { |password| described_class.password_pwned?(password) }

        expect(results.all?).to be true
      end
    end

    context 'when the password has not been pwned' do
      it 'returns false' do
        expect(described_class.password_pwned?(generate_random_valid_password)).to be false
      end
    end
  end
end

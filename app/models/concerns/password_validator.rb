module PasswordValidator
  extend ActiveSupport::Concern

  included do
    validates :password, presence: true, length: { within: 10..200 }
    validates :password_confirmation, presence: true
    validates :password, confirmation: { case_sensitive: true }

    validates :password, format: { with: /(?=.*[A-Z])/, message: :invalid_no_capitals }
    validates :password, format: { with: /(?=.*[0-9])/, message: :invalid_no_number }
    validate :validate_symbols
  end

  private

  VALID_SYMBOLS = %r{^[=+\-\^$*.\[\]{}()?"!@\#%&/\\,><':;|_~`]+$}.freeze

  def validate_symbols
    password_symbols = password.delete('0-9a-zA-Z')

    return if password_symbols.blank?

    errors.add(:password, :invalid_symbol) unless password_symbols.match?(VALID_SYMBOLS)
  end
end

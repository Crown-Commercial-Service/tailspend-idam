module PasswordValidator
  extend ActiveSupport::Concern

  included do
    validates :password, presence: true, length: { within: 10..200 }
    validates :password_confirmation, presence: true
    validates :password, confirmation: { case_sensitive: true }

    validates :password, format: { with: /(?=.*[A-Z])/, message: :invalid_no_capitals }
    validates :password, format: { with: /(?=.*[0-9])/, message: :invalid_no_number }
    validates :password, format: { with: %r{(?=.*[=+-^$*.\[\]{}()?"!@#%&/\\,><':;|_~`])}, message: :invalid_no_symbol }

    validate :validate_symbols, :validate_password_not_pwned
  end

  private

  VALID_SYMBOLS = %r{^[=+-\^$*.\[\]{}()?"!@\#%&/\\,><':;|_~`]+$}

  def validate_symbols
    password_symbols = password.delete('0-9a-zA-Z')

    return if password_symbols.blank?

    errors.add(:password, :invalid_symbol) unless password_symbols.match?(VALID_SYMBOLS)
  end

  def validate_password_not_pwned
    return if errors.any?(:password) || errors.any?(:password_confirmation)

    errors.add(:password, :invalid_pwned) if PwnedPassword.password_pwned?(password)
  end
end

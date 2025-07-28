module PwnedPasswords
  class TestPassword
    include ActiveModel::Validations

    attr_reader :password

    validates :password, presence: true, length: { within: 10..200 }
    validates :password, format: { with: /(?=.*[A-Z])/, message: :invalid_no_capitals }
    validates :password, format: { with: /(?=.*[0-9])/, message: :invalid_no_number }
    validate :validate_symbols

    def initialize(password)
      @password = password
    end

    private

    VALID_SYMBOLS = %r{^[=+-\^$*.\[\]{}()?"!@\#%&/\\,><':;|_~`]+$}

    def validate_symbols
      password_symbols = password.delete('0-9a-zA-Z')

      return if password_symbols.blank?

      errors.add(:password, :invalid_symbol) unless password_symbols.match?(VALID_SYMBOLS)
    end
  end

  def self.complete_tasks
    Rails.logger.info 'Importing pwned passwords from SecLists'
    import_pwned_passwords
    Rails.logger.info 'Pwned passwords import complete'
  rescue StandardError => e
    ActiveRecord::Base.logger.level = Logger::DEBUG

    Rails.logger.info "PWNED PASSWORDS IMPORT FAILED: #{e.message}"
    Rollbar.log('error', e)
  end

  # rubocop:disable Rails/SkipsModelValidations
  def self.import_pwned_passwords
    insert_data = full_password_list
                  .select { |password| password.length >= 10 && TestPassword.new(password).valid? }
                  .map { |password| { password: } }

    ActiveRecord::Base.logger.level = Logger::INFO

    ActiveRecord::Base.transaction do
      PwnedPassword.delete_all
      PwnedPassword.insert_all(insert_data)
      Rails.logger.info "#{insert_data.length} passwords inserted into pwned passwords table"
    end

    ActiveRecord::Base.logger.level = Logger::DEBUG
  end
  # rubocop:enable Rails/SkipsModelValidations

  def self.full_password_list
    if Rails.env.test?
      passwords = []

      Rails.root.join('data/test_pwned_passwords.json').open('r') do |file|
        passwords = JSON.parse(file.read)
      end

      passwords
    else
      # The source for this can be found in https://github.com/danielmiessler/SecLists/blob/master/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt
      pwned_passwords_json = JSON.parse(Net::HTTP.get(URI(ENV.fetch('PWNED_PASSWORDS_URL'))))

      encoded_list = pwned_passwords_json['content']

      Base64.decode64(encoded_list).split("\n")
    end
  end
end

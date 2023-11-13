class PwnedPassword < ApplicationRecord
  def self.password_pwned?(password)
    exists?(password:)
  end
end

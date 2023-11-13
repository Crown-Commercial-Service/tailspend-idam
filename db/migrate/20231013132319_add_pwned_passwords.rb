class AddPwnedPasswords < ActiveRecord::Migration[7.0]
  class PwnedPasswordTable < ApplicationRecord
    self.table_name = :pwned_passwords
  end

  def up
    PwnedPasswordTable.reset_column_information
    PwnedPasswords.complete_tasks
  end

  def down
  end
end

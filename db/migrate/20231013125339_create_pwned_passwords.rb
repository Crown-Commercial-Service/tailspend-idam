class CreatePwnedPasswords < ActiveRecord::Migration[7.0]
  def change
    create_table :pwned_passwords, id: false do |t|
      t.string :password, limit: 60, index: true
    end
  end
end

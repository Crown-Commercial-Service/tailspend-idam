class CreateClientCalls < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'pgcrypto'
    create_table :client_calls, id: :uuid do |t|
      t.string :access_token
      t.string :refresh_token
      t.string :id_token
      t.string :token_type
      t.text :expires_in
      t.string :sub
      t.string :client_id
      t.text :nonce
      t.timestamps
    end
  end
end

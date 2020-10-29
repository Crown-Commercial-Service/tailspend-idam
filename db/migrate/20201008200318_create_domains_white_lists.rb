class CreateDomainsWhiteLists < ActiveRecord::Migration[6.0]
  def change
    create_table :domains_white_lists, id: :uuid  do |t|
      t.string :url
      t.boolean :active, :default => false
      t.timestamps
    end
  end
end

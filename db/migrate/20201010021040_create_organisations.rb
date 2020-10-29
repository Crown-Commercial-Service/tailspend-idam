class CreateOrganisations < ActiveRecord::Migration[6.0]
  def change
    create_table :organisations, id: :uuid  do  |t|
      t.string :supllier_name
      t.boolean :active, :default => false
      t.timestamps
    end
  end
end

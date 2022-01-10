class AddColumnsToOrganisationsTable < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :urn, :integer
    add_column :organisations, :summary_line, :text
    add_index :organisations, :summary_line
  end
end

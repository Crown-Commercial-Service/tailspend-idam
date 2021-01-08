class FixSpellingError < ActiveRecord::Migration[6.0]
  def change
    rename_column :organisations, :supllier_name, :supplier_name
  end
end

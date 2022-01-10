class RenameSupplierNameToOrganisationName < ActiveRecord::Migration[6.0]
  def change
    rename_column :organisations, :supplier_name, :organisation_name
  end
end

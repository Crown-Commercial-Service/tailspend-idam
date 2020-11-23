class Organisation < ApplicationRecord
  def self.find_organisation(search)
    Organisation.where(active: true).where(['lower(supplier_name) LIKE ?', "%#{search.downcase}%"]).pluck(:supplier_name)
  end
end

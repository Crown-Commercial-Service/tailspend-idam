class Organisation < ApplicationRecord
  def self.find_organisation(search)
    Organisation.where(active: true).where(['lower(supllier_name) LIKE ?', "%#{search.downcase}%"]).pluck(:supllier_name)
  end
end

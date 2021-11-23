class Organisation < ApplicationRecord
  def self.find_organisation(search)
    Organisation.where(active: true).where(['lower(organisation_name) LIKE ?', "%#{search&.downcase}%"]).pluck(:organisation_name)
  end
end

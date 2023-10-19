class Organisation < ApplicationRecord
  def self.search_organisations(search)
    Organisation.where(active: true).where(['lower(summary_line) LIKE ?', "%#{search&.downcase}%"]).pluck(:summary_line)
  end

  def self.find_organisation(summary_line)
    Organisation.find_by(summary_line:)
  end
end

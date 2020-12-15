class ChangeDomainWhitListToDomainAllowList < ActiveRecord::Migration[6.0]
  def change
    rename_table :domains_white_lists, :allowed_email_domains
  end
end

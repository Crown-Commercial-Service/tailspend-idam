module Domains
  # rubocop:disable Rails/SkipsModelValidations
  def self.import_domains
    csv = Roo::CSV.new(csv_path, { csv_options: { liberal_parsing: true } })
    insert_data = []

    csv.column(1)[1..].each do |url|
      insert_data << {
        'url': url,
        'active': true,
        'created_at': DateTime.current,
        'updated_at': DateTime.current
      }
    end

    AllowedEmailDomain.insert_all(insert_data)
  rescue StandardError => e
    Rails.logger.debug e
    Rollbar.log('error', e)
  end
  # rubocop:enable Rails/SkipsModelValidations

  def self.remove_duplicates
    query = <<-SQL.squish
      DELETE FROM
        allowed_email_domains a
          USING allowed_email_domains b
      WHERE
        a.id < b.id
        AND a.url = b.url;
    SQL

    ActiveRecord::Base.connection.execute(query)
  rescue StandardError => e
    Rails.logger.debug e
    Rollbar.log('error', e)
  end

  def self.csv_path
    URI.open(ENV['EMAIL_DOMAINS_CSV_BLOB'])
  end
end

namespace :domains do
  desc 'Import email domains into database'
  task import: :environment do
    p 'Importing email domains from Salesforce'
    Domains.import_domains
    p 'Removing duplicate email domains from database'
    Domains.remove_duplicates
    p 'Email domains import complete'
  end
end

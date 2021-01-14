module Domains
  def self.complete_tasks
    p 'Importing email domains from Salesforce'
    import_domains
    p 'Removing duplicate email domains from database'
    remove_duplicates
    p 'Email domains import complete'
  rescue StandardError => e
    p "EMAIL DOMAINS IMPORT FAILED: #{e.message}"
    ActiveRecord::Base.logger.level = Logger::DEBUG

    Rails.logger.debug e
    Rollbar.log('error', e)
  end

  # rubocop:disable Rails/SkipsModelValidations
  def self.import_domains
    csv = Roo::CSV.new(csv_path, { csv_options: { liberal_parsing: true } })

    insert_data = csv.column(1)[1..].map { |url| get_email_domain_row(url) }

    ActiveRecord::Base.logger.level = Logger::INFO

    AllowedEmailDomain.insert_all(insert_data)

    ActiveRecord::Base.logger.level = Logger::DEBUG
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
  end

  def self.csv_path
    URI.open(ENV['EMAIL_DOMAINS_CSV_BLOB'])
  end

  def self.get_email_domain_row(url)
    {
      'url': url,
      'active': true,
      'created_at': DateTime.current,
      'updated_at': DateTime.current
    }
  end
end

namespace :domains do
  desc 'Import email domains into database'
  task import: :environment do
    Domains.complete_tasks
  end
end

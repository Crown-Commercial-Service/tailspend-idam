module SalesforceImport
  module Domains
    def self.complete_tasks
      Rails.logger.info 'Importing email domains from Salesforce'
      import_domains
      Rails.logger.info 'Adding additional email domains'
      add_additional_domains
      Rails.logger.info 'Removing duplicate email domains from database'
      remove_duplicates
      Rails.logger.info 'Email domains import complete'
    rescue StandardError => e
      ActiveRecord::Base.logger.level = Logger::DEBUG

      Rails.logger.info "EMAIL DOMAINS IMPORT FAILED: #{e.message}"
      Rollbar.log('error', e)
    end

    # rubocop:disable Rails/SkipsModelValidations
    def self.import_domains
      csv = Roo::CSV.new(csv_path, { csv_options: { liberal_parsing: true } })

      insert_data = csv.column(1)[1..].map { |url| get_email_domain_row(url) }

      ActiveRecord::Base.logger.level = Logger::INFO

      ActiveRecord::Base.transaction do
        AllowedEmailDomain.delete_all
        AllowedEmailDomain.insert_all(insert_data)
      end

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

    def self.add_additional_domains
      return unless ENV['ADDITIONAL_EMAILS_REQUIRED'] == 'TRUE'

      email_list = ENV['ADDITIONAL_EMAILS'].split(',')

      email_list.each do |email_domain|
        AllowedEmailDomain.create(url: email_domain, active: true)
      end
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
end

module SalesforceImport
  module Organisations
    def self.complete_tasks
      Rails.logger.info 'Importing organisations from Salesforce'
      import_organisations
      Rails.logger.info 'Removing duplicate Organisations from database'
      remove_duplicates
      Rails.logger.info 'Organisations import complete'
    rescue StandardError => e
      ActiveRecord::Base.logger.level = Logger::DEBUG

      Rails.logger.info "ORGANISATIONS IMPORT FAILED: #{e.message}"
      Rollbar.log('error', e)
    end

    # rubocop:disable Rails/SkipsModelValidations
    def self.import_organisations
      csv = Roo::CSV.new(csv_path, { csv_options: { liberal_parsing: true } })

      insert_data = csv.column(1)[1..].map { |organisation_name| get_organisation_row(organisation_name) }

      ActiveRecord::Base.logger.level = Logger::INFO

      ActiveRecord::Base.transaction do
        Organisation.delete_all
        Organisation.insert_all(insert_data)
      end

      ActiveRecord::Base.logger.level = Logger::DEBUG
    end
    # rubocop:enable Rails/SkipsModelValidations

    def self.remove_duplicates
      query = <<-SQL.squish
      DELETE FROM
        organisations a
          USING organisations b
      WHERE
        a.id < b.id
        AND a.organisation_name = b.organisation_name;
      SQL

      ActiveRecord::Base.connection.execute(query)
    end

    def self.csv_path
      if Rails.env.test?
        Rails.root.join('data/test_organisations.csv')
      else
        URI.open(ENV['ORGANISATIONS_CSV_BLOB'])
      end
    end

    def self.get_organisation_row(organisation_name)
      {
        'organisation_name': format_organisation_name(organisation_name),
        'active': !organisation_inactive?(organisation_name),
        'created_at': DateTime.current,
        'updated_at': DateTime.current
      }
    end

    def self.format_organisation_name(organisation_name)
      organisation_name.force_encoding('UTF-8').squish
    end

    def self.organisation_inactive?(organisation_name)
      organisation_name.downcase.starts_with?('(closed)') || organisation_name == '*REDACTED*'
    end
  end
end

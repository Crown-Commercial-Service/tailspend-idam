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

    HEADERS = ['CustomerName', 'UniqueReferenceNumber', 'Address', 'City', 'Postcode'].freeze

    # rubocop:disable Rails/SkipsModelValidations
    def self.import_organisations
      insert_data = []

      CSV.foreach(csv_path, liberal_parsing: true, encoding: 'bom|utf-8', headers: true) do |row|
        insert_data << get_organisation_row(transform_row_to_hash(row))
      end

      ActiveRecord::Base.logger.level = Logger::INFO

      ActiveRecord::Base.transaction do
        Organisation.delete_all
        Organisation.insert_all(insert_data)
      end

      ActiveRecord::Base.logger.level = Logger::DEBUG
    end
    # rubocop:enable Rails/SkipsModelValidations

    def self.remove_duplicates
      query = <<~SQL.squish
        DELETE FROM
          organisations a
            USING organisations b
        WHERE
          a.id < b.id
          AND a.summary_line = b.summary_line;
      SQL

      ActiveRecord::Base.connection.execute(query)
    end

    def self.csv_path
      if Rails.env.test?
        Rails.root.join('data/test_organisations.csv')
      else
        URI.parse(ENV.fetch('ORGANISATIONS_CSV_BLOB', nil)).open
      end
    end

    def self.get_organisation_row(row)
      {
        organisation_name: row['CustomerName'],
        active: !organisation_inactive?(row['CustomerName']),
        created_at: DateTime.current,
        updated_at: DateTime.current,
        urn: row['UniqueReferenceNumber'].to_i,
        summary_line: get_summary_line(row)
      }
    end

    def self.get_summary_line(row)
      if row['Address'].nil? && row['City'].nil? && row['Postcode'].nil?
        row['CustomerName']
      else
        "#{row['CustomerName']} (#{[row['Address'], row['City'], row['Postcode']].compact.join(', ')})"
      end
    end

    def self.transform_row_to_hash(row)
      row.to_h.slice(*HEADERS).transform_values { |value| convert_to_nil(format_string(value)) }
    end

    def self.format_string(string)
      string&.force_encoding('UTF-8')&.squish
    end

    def self.organisation_inactive?(organisation_name)
      organisation_name.downcase.starts_with?('(closed)') || organisation_name == '*REDACTED*'
    end

    def self.convert_to_nil(string)
      string == 'NULL' || string&.empty? ? nil : string
    end
  end
end

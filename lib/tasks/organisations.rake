module Organisations
  # rubocop:disable Rails/SkipsModelValidations
  def self.import_organisations
    csv = Roo::CSV.new(spreadsheet_path, { csv_options: { liberal_parsing: true } })
    insert_data = []

    csv.column(1)[1..].each do |supplier_name|
      insert_data << {
        'supplier_name': format_supplier_name(supplier_name),
        'active': !supplier_inactive?(supplier_name),
        'created_at': DateTime.current,
        'updated_at': DateTime.current
      }
    end

    Organisation.delete_all
    Organisation.insert_all(insert_data)
  rescue StandardError => e
    Rails.logger.debug e
    Rollbar.log('error', e)
  end
  # rubocop:enable Rails/SkipsModelValidations

  def self.remove_duplicates
    query = <<-SQL.squish
      DELETE FROM
        organisations a
          USING organisations b
      WHERE
        a.id < b.id
        AND a.supplier_name = b.supplier_name;
    SQL

    ActiveRecord::Base.connection.execute(query)
  rescue StandardError => e
    Rails.logger.debug e
    Rollbar.log('error', e)
  end

  def self.spreadsheet_path
    if Rails.env.test?
      Rails.root.join('data/test_organisations.csv')
    else
      URI.open(ENV['ORGANISATIONS_CSV_BLOB'])
    end
  end

  def self.format_supplier_name(supplier_name)
    supplier_name.force_encoding('UTF-8').squish
  end

  def self.supplier_inactive?(supplier_name)
    supplier_name.downcase.starts_with?('(closed)') || supplier_name == '*REDACTED*'
  end
end

namespace :organisations do
  desc 'Import organisations into database'
  task import: :environment do
    p 'Importing organisations from Salesforce'
    Organisations.import_organisations
    p 'Removing duplicate Organisations from database'
    Organisations.remove_duplicates
    p 'Organisations import complete'
  end
end

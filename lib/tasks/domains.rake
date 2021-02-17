namespace :domains do
  desc 'Import email domains into database'
  task import: :environment do
    SalesforceImport::Domains.complete_tasks
  end
end

namespace :organisations do
  desc 'Import organisations into database'
  task import: :environment do
    SalesforceImport::Organisations.complete_tasks
  end
end

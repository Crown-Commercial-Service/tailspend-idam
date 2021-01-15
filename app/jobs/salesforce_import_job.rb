class SalesforceImportJob < ApplicationJob
  queue_as :default

  def perform
    SalesforceImport::Organisations.complete_tasks
    SalesforceImport::Domains.complete_tasks
  end
end

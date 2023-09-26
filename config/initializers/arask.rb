if ENV.fetch('PREVENT_ARASK', '0') == '1'  # Set to '1' to disable Arask job setup
  Rails.logger.info 'Skipping Arask setup'
else
  Rails.logger.info 'Setting up Arask'
  Arask.setup do |arask|
    arask.create job: 'SalesforceImportJob', cron: '0 */1 * * *', run_first_time: true if Rails.env.production?

    # On exceptions, send email with details
    arask.on_exception email: 'CSI@crowncommercial.gov.uk'
  end
end

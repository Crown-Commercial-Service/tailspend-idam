Arask.setup do |arask|
  arask.create task: 'organisations:import', cron: '0 1 * * *', run_first_time: true if Rails.env.production?

  # On exceptions, send email with details
  arask.on_exception email: 'CSI@crowncommercial.gov.uk'
end

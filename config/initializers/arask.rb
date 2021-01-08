Arask.setup do |arask|
  if Rails.env.production?
    arask.create task: 'organisations:import', cron: '0 1 * * *', run_first_time: true
    arask.create task: 'domains:import', cron: '0 1 * * *', run_first_time: true
  end

  # On exceptions, send email with details
  arask.on_exception email: 'CSI@crowncommercial.gov.uk'
end

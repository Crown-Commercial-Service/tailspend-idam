if defined? RSpec
  require 'rspec/core/rake_task'

  task(:spec).clear
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.verbose = false

    # Rake::Task['db:static'].invoke
    puts 'Adding test data to database'
    system('rake organisations:import RAILS_ENV=test')
    system('rake pwned_passwords:import RAILS_ENV=test')
    puts 'Data added to database'
  end
end

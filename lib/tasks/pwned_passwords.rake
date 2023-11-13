namespace :pwned_passwords do
  desc 'Import pwned passwords into database'
  task import: :environment do
    PwnedPasswords.complete_tasks
  end
end

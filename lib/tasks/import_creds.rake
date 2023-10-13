namespace :import_creds do
  desc 'Import creds'
  task import: :environment do
    vcap_services = JSON.parse(ENV.fetch('VCAP_SERVICES', nil))
    puts 'Pulling creds'
    s3_creds = Aws::Credentials.new(vcap_services['aws-s3-bucket'][0]['credentials']['aws_access_key_id'], vcap_services['aws-s3-bucket'][0]['credentials']['aws_secret_access_key'])
    s3 = Aws::S3::Resource.new(region: vcap_services['aws-s3-bucket'][0]['credentials']['aws_region'], credentials: s3_creds)
    source_obj_key = s3.bucket(vcap_services['aws-s3-bucket'][0]['credentials']['bucket_name']).object('key/master.key')
    source_obj_cred = s3.bucket(vcap_services['aws-s3-bucket'][0]['credentials']['bucket_name']).object('creds/credentials.yml.enc')
    source_obj_key.get(response_target: 'config/master.key')
    source_obj_cred.get(response_target: 'config/credentials.yml.enc')
  end
end

require 'rollbar'

def config_vault
  vcap_services = JSON.parse(ENV.fetch('VCAP_SERVICES', nil))
  key_store_path = ''
  Vault.configure do |config|
    vcap_services['hashicorp-vault'].each do |key, _value|
      key_store_path = "#{key['credentials']['backends_shared']['space']}/#{ENV.fetch('SERVER_ENV_NAME', nil)}"
      config.address = key['credentials']['address']
      config.token = key['credentials']['auth']['token']
    end
    config.ssl_verify = true
  end
  set_env(key_store_path)
end

# rubocop:disable Naming/AccessorMethodName
def set_env(storage_path)
  env_vars = Vault.logical.read(storage_path)
  env_vars.data.each do |env_key, env_value|
    ENV[env_key.to_s] = env_value.to_s
  end
end
# rubocop:enable Naming/AccessorMethodName

# config_vault if ENV['SERVER_ENV_NAME'].present?

Rack::Attack.throttle('requests to organisation-search api by ip ', limit: 25, period: 5.minutes) do |request|
  request.ip if request.path == '/api/v1/organisation-search'
end

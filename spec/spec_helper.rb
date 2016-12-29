$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'net-http2'
require 'rspec'

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }

RSpec.configure do |config|
  config.order = :random
  config.include NetHttp2::ApiHelpers
end

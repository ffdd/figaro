require "bundler"
Bundler.setup

if ENV.has_key?("COVERAGE")
  require 'simplecov'
  SimpleCov.start do
    add_filter %r{^/spec/}
  end
end

require "figaro"

Bundler.require(:test)

Dir[File.expand_path("../support/*.rb", __FILE__)].each { |f| require f }

require 'aruba/rspec'

RSpec.configure do |config|
  config.include ArubaHelpers, type: :aruba
end

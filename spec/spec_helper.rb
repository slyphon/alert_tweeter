require 'rspec'
require 'alert_tweeter'
require 'evented-spec'


Dir[File.expand_path(File.join(File.dirname(__FILE__), "support/**/*.rb"))].each {|f| require f}

Rspec.configure do |config|
  config.mock_with :rspec
end


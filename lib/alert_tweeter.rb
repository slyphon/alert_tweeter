require "alert_tweeter/version"

require 'slop'
require 'twitter'

%w[ core_ext/module/attribute_accessors
    core_ext/class/attribute_accessors 
    core_ext/string/strip
    core_ext/module/aliasing
].each do |p|
  require "active_support/#{p}"
end

module AlertTweeter
  mattr_accessor :root, :instance_writer => false 

  DEFAULT_CONFIG_PATH = File.expand_path('~/.alert_tweeter.yml')

  class Command

    def configure_client(path)
      require 'yaml'

      hash = YAML.load_file(path).fetch('auth')

      Twitter.configure do |config|
        %w[consumer_key consumer_secret oauth_token oauth_token_secret].each do |k|
          config.__send__(:"#{k}=", hash.fetch(k))
        end
      end
    end


    def run!(*args)
      args << '-h' if args.empty?

      @opts = Slop.parse!(args, :strict => true, :help => true) do
        banner <<-EOS.strip_heredoc
          Usage: #{File.basename($0)} [opts] 

          Will direct-message the configured users about service problems. Command-line options
          are provided that more-or-less match their nagios macro counterparts.

        EOS

        on :f,  :config=,             'path to the config file to use', :default => DEFAULT_CONFIG_PATH
        on :h,  :hostname=,           'host name where the alert is triggered', :required => true
        on :s,  :servicedesc=,        'description of the service'
        on      :servicestate=,       'string indicating the current state of the service'
        on      :servicedurationsec=, 'number of seconds the service has been in the current state'
        on      :serviceoutput=,      'first line of text output from the last service check'
        on      :timet=,              'seconds since unix epoch'

        on      :ack,                 'this is an acknowledgement'
        on      :service_alert,       'this is a service alert'
        on      :host_alert,          'this is a host alert'


      end
    end
  end
end


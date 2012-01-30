$LOAD_PATH.unshift(File.expand_path('..', __FILE__)).uniq!

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

  DEFAULT_CONFIG_PATH = '/etc/alert_tweeter.yml'

  class Command
    attr_reader :opts

    def self.run!(*a, &b)
      new.run!(*a, &b)
    end

    def config
      @config ||= YAML.load_file(opts[:config])
    end

    def notify_users
      @config.fetch('notify_users')
    end

    def configure_client!(path)
      require 'yaml'

      hash = config.fetch('auth')

      Twitter.configure do |c|
        %w[consumer_key consumer_secret oauth_token oauth_token_secret].each do |k|
          c.__send__(:"#{k}=", hash.fetch(k))
        end
      end
    end

    def timestamp
      Time.at(timet.to_i).strftime('%Y-%m-%d %H:%M:%S')
    end

    def send_notification(message)
      notify_users.each do |user|
        Twitter.direct_message_create(user, message)
      end
    end

    def service_notify!
      send_notification <<-EOS.strip_heredoc[0...140]
        #{notification_type} #{host_name}/#{service_desc} #{event_state}
        #{timestamp}
        #{service_output}
      EOS
    end

    def host_notify!
      send_notification <<-EOS.strip_heredoc[0...140]
        #{notification_type} #{host_name} #{event_state}
        #{timestamp}
        #{host_output}
      EOS
    end

    def run!(*args)
      args << '-h' if args.empty?

      @opts = Slop.parse!(args, :strict => true, :help => true) do
        banner <<-EOS.strip_heredoc
          Usage: #{File.basename($0)} [opts] 

          Will direct-message the configured users about service problems. Command-line options
          are provided that more-or-less match their nagios macro counterparts.
        EOS

        on :f, :config,                 'path to the config file to use', true, :default => DEFAULT_CONFIG_PATH

        on :n, :notification_type,      'string describing the type of notification being sent', true

        on :s, :event_state,            'string indicating the state of event-generating object', true, :default => 'UNKNOWN'
        on :y, :event_state_type,       'HARD or SOFT', true

        on :H, :host_name,              'host name where the alert is triggered', true, :required => true
        on :a, :host_address,           'IP address of the host', true
        on :A, :host_attempt,           'number of the current re-check', true, :as => :integer
        on :O, :host_output,            'output from host check', true
        on :U, :host_duration_sec,      'number of seconds the host has spent in the current state', true, :as => :integer

        on :d, :service_desc,           'description of the service', true
        on :a, :service_attempt,        'number of the current re-check', true, :as => :integer
        on :u, :service_duration_sec,   'number of seconds the service has been in the current state', true, :as => :integer
        on :o, :service_output,         'first line of text output from the last service check', true

        on :t, :timet,                  'seconds since unix epoch', true, :as => :integer, :default => Time.now.to_i
      end

      if opts.help?
        $stderr.puts opts.help
        exit 1
      end

      unless opts[:service_output] or opts[:host_output]
        $stderr.puts "ERROR: You must specify either a --service_output or --host_output option"
        exit 1
      end

      configure_client!(opts[:config])

      if opts[:service_output]
        service_notify!
      else
        host_notify!
      end
    end

    private
      def method_missing(name, *a, &b)
        namesym = name.to_sym
        if val = opts[namesym]
          return val
        else
          super
        end
      end
  end
end


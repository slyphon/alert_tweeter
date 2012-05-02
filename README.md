## Alert tweeter

A dirt-simple way of tweeting nagios alerts

## Configuration

* You'll need to [register an app](https://dev.twitter.com/apps).
* You'll need a YAML file like:

```
---
app_name: your-clever-app-name
notify_users:
- annoy
- all_of_these
- twitter_uesrs
auth:
  consumer_key: YOUR_CONSUMER_KEY
  consumer_secret: YOUR_CONSUMER_SECRET
  oauth_token: YOUR_OAUTH_TOKEN
  oauth_token_secret: YOUR_OAUTH_TOKEN_SECRET
```

then in your nagios config, you'll need something like:

```
define command {
  command_name service-notify-by-twitter
  command_line /usr/local/rvm/bin/rvm-exec 1.9.2 tweet-alert \
      --config=/path/to/the/config.yml \
      --notification_type=$NOTIFICATIONTYPE$ \
      --event_state=$SERVICESTATE$ \
      --event_state_type=$SERVICESTATETYPE$ \
      --host_name=$HOSTALIAS$ \
      --host_address=$HOSTADDRESS$ \
      --service_desc=$SERVICEDESC$ \
      --service_attempt=$SERVICEATTEMPT$ \
      --service_duration_sec=$SERVICEDURATIONSEC$ \
      --service_output="$SERVICEOUTPUT$" 
}

define command {
  command_name host-notify-by-twitter
  command_line /usr/local/rvm/bin/rvm-exec 1.9.2 tweet-alert \
      --config=/path/to/the/config.yml \
      --notification_type=$NOTIFICATIONTYPE$ \
      --event_state=$HOSTSTATE$  \
      --event_state_type=$HOSTSTATETYPE$ \
      --host_name=$HOSTALIAS$ \
      --host_address=$HOSTADDRESS$ \
      --host_attempt=$HOSTATTEMPT$ \
      --host_duration_sec=$HOSTDURATIONSEC$ \
      --host_output="$HOSTOUTPUT$"
}

define contact {
  name                            twitter-contact
  service_notification_period     24x7
  host_notification_period        24x7
  service_notification_options    w,u,c,r,f,s
  host_notification_options       d,u,r,f,s
  service_notification_commands   service-notify-by-twitter
  host_notification_commands      host-notify-by-twitter
  register                        0
}

define contactgroup {
  contactgroup_name admins-twitter
  alias             Sysamdin Twitter
  members           twitter-dummy
}

# as of alert_tweeter-0.0.2 the contacts are determined by the alert_tweeter.yml file
# managed by chef in the icinga recipe
define contact {
  use                           twitter-contact
  contact_name                  twitter-dummy
  service_notification_options  c,r,f
  host_notification_options     d,u,r,f
  #                             ^^^^^^^--- ha! twitter dummy! durf! get it!?
}
```

(GAH! I *hate* nagios! could they make it MORE verbose, error-prone, and annoying?!)

Obviously replace `--config=/path/to/the/config.yml` with the path to the *actual* config. I use rvm, if you don't, or if you're weird and like rbenv, you'll need to adjust the above commands.




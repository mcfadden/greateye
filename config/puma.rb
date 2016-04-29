workers 2
threads 2, 3

# We do phased restarts, so we can't preload the app.
# preload_app!
prune_bundler

rackup      DefaultRackup
environment ENV['RACK_ENV'] || 'development'

directory '/www/greateye/current'
bind "unix:///www/greateye/current/tmp/sockets/puma.greateye.sock"
state_path "/www/greateye/current/tmp/pids/puma.state"
pidfile "/www/greateye/current/tmp/pids/puma.pid"
stdout_redirect '/www/greateye/current/log/puma.stdout.log', '/www/greateye/current/log/puma.stderr.log', true
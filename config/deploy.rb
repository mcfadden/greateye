# config valid only for current version of Capistrano
lock '3.5.0'

set :application, 'greateye'
set :repo_url, 'git@bitbucket.org:benmcfadden/greateye.git'

# set :rbenv_type, :user # or :system, depends on your rbenv setup
# set :rbenv_ruby, File.read('.ruby-version').strip
#
# set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
# set :rbenv_map_bins, %w{rake gem bundle ruby rails}
# set :rbenv_roles, :all # default value

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/www/greateye'

# Default value for :scm is :git
set :scm, :git

# Default value for :log_level is :debug
#set :log_level, :info
set :log_level, :debug

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Defaults to nil (no asset cleanup is performed)
# If you use Rails 4+ and you'd like to clean up old assets after each deploy,
# set this to the number of versions to keep
set :keep_assets, 2

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/secrets.yml', 'config/application.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system', 'tmp/camera-event-assets')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  namespace :services do
    desc "Restart All Services"
    task :restart do
      on roles(:web) do
        within release_path do
          with rails_env: fetch(:rails_env) do
            execute "/usr/local/bin/pumactl --config-file /www/greateye/current/config/puma.rb phased-restart"
            execute "sudo systemctl restart sidekiq"
            execute "sudo systemctl restart clockwork"
          end
        end
      end
    end
  end
end

after  "deploy:published", "deploy:services:restart"

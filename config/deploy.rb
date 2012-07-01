# Configure these lines for your app prior to launch.
# Application Name is the folder it will deploy to.
# Script Name is the name of the logfile and the god script.
# Start Command is the command god will issue to start the process.

APPLICATION_NAME = "Scheduler"
SCRIPT_NAME = "scheduler"
REPOSITORY = "git://github.com/marktabler/scheduler.git"

# Unicorn start example
# START_COMMAND = "unicorn /apps/#{APPLICATION_NAME}/current/config.ru -p 3001"

# Rainbows start example
# START_COMMAND = "rainbows /apps/#{APPLICATION_NAME}/current/faye.ru -c /apps/#{APPLICATION_NAME}/current/rainbows.conf -E production -p 9000"

# This assumes you want to launch to Falling Foundry.
# If you want to launch to Falling Garden, launch with
# DEPLOY_MODE="staging" cap deploy

PRODUCTION_SERVER = "fallingfoundry.com"
STAGING_SERVER = "fallinggarden.com"
MODE = ENV["DEPLOY_MODE"] || "staging"
SERVER = MODE == "staging" ? STAGING_SERVER : PRODUCTION_SERVER


$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
server SERVER, :web, :db, :app, primary: true
set :user, "root"
set :application, APPLICATION_NAME

set :deploy_to, "/apps/#{application}"
set :deploy_via, :remote_cache

set :scm, "git"
set :repository, REPOSITORY
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

namespace :deploy do
  namespace :assets do
    task :precompile do
      logger.info "Skipping precompilation of assets"
    end
  end
end

namespace :deploy do
  task :bundle do
    run "cd /apps/#{application}/current && bundle install --system"
  end
  task :start do
    #crontab -e / 5 5 * * * cd /apps/Scheduler && bundle exec ruby lib/scheduler
  end
  after "deploy", "deploy:bundle"
 
end
set :use_sudo, false

default_run_options[:pty] = true

set :application, "rails3_fcgi"
set :domain,      "#{application}.lan"
set :user,        "krg"  # The server's user for deploys
set :repository,  "git@github.com:dre3k/#{application}.git"
set :deploy_to,   "ssh://#{user}@#{domain}/home/#{user}/www/#{application}"

set :scm, :git

role :web, domain  # Your HTTP server, Apache/etc
role :app, domain  # This may be the same as your `Web` server
role :db, domain, :primary => true  # This is where Rails migrations will run

ssh_options[:forward_agent] = true

set :brach, "master"

set :deploy_via, :remote_cache

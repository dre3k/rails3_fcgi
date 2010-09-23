set :use_sudo, false
default_run_options[:pty] = true

set :application, "rails3_fcgi"
set :domain,      "#{application}.lan"
set :user,        "krg"  # The server's user for deploys
set :repository,  "git@github.com:dre3k/#{application}.git"
set :deploy_to,   "/home/#{user}/www/#{application}"

set :scm, :git

role :web, domain  # Your HTTP server, Apache/etc
role :app, domain  # This may be the same as your `Web` server
role :db, domain, :primary => true  # This is where Rails migrations will run

ssh_options[:forward_agent] = true
set :brach, "master"
set :deploy_via, :remote_cache

deploy.task :db_link do
  run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  run "ln -nfs #{shared_path}/db/production.sqlite3 #{release_path}/db/production.sqlite3"
end

after "deploy:update_code", "deploy:db_link"
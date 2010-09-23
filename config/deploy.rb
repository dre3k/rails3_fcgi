set :application, "rails3_fcgi"
set :user,        "krg"  # The server's user for deploys
set :domain,      "#{application}.lan"
set :repository,  "git@github.com:dre3k/#{application}.git"
set :deploy_to,   "/home/#{user}/www/#{application}"

set :scm, :git

role :web, domain  # Your HTTP server, Apache/etc
role :app, domain  # This may be the same as your `Web` server
role :db, domain, :primary => true  # This is where Rails migrations will run

default_run_options[:pty] = true
set :use_sudo, false
ssh_options[:forward_agent] = true
set :brach, "master"
set :deploy_via, :remote_cache
set :scm_verbose, true

deploy.task :db_link do
  run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  run "ln -nfs #{shared_path}/db/production.sqlite3 #{release_path}/db/production.sqlite3"
  run "chmod 0777 #{release_path}/db"
end
after "deploy:update_code", "deploy:db_link"

namespace :deploy do
  task :restart do
    run "#{sudo} killall #{application}.fcgi"
    run "wget #{domain} --spider -O  -"
  end
end

# Rails3-FastCGI

Simple Rails3 application configured to be deployed on apache2 with fastCGI and
capistrano.
You need to have FastCGI library for Ruby and FastCGI module for apache2 installed.

# Files of interest:

## Apache2 site configuration
<pre>
< VirtualHost rails3_fcgi.lan:80 >
  DefaultInitEnv RAILS_ENV production
  DocumentRoot /home/krg/www/rails3_fcgi/current/public
  < Directory /home/krg/www/rails3_fcgi/current/public >
    Options ExecCGI FollowSymLinks
    AllowOverride all
    Order allow,deny
    Allow from all
  < /Directory >
< /VirtualHost >
</pre>

## public/.htaccess
<pre>
SetEnv RAILS_RELATIVE_URL_ROOT /rails3_fcgi

RewriteEngine On

RewriteRule ^(stylesheets/.*)$ - [L]
RewriteRule ^(javascripts/.*)$ - [L]
RewriteRule ^(images/.*)$ - [L]

RewriteRule ^$ index.html [QSA]
RewriteRule ^([^.]+)$ $1.html [QSA]
RewriteCond %{REQUEST_FILENAME} !-f

RewriteRule ^(.*)$ rails3_fcgi.fcgi [E=X-HTTP_AUTHORIZATION:%{HTTP:Authorization},QSA,L]
</pre>

## public/rails3_fcgi.fcgi
<pre>
#!/usr/bin/ruby

require_relative '../config/environment'

class Rack::PathInfoRewriter
  def initialize(app)
    @app = app
  end

  def call(env)
    env.delete('SCRIPT_NAME')
    parts = env['REQUEST_URI'].split('?')
    env['PATH_INFO'] = parts[0]
    env['QUERY_STRING'] = parts[1].to_s
    @app.call(env)
  end
end

Rack::Handler::FastCGI.run  Rack::PathInfoRewriter.new(Rails3Fcgi::Application)
</pre>

## config/routes.rb
<pre>
Rails3Fcgi::Application.routes.draw do
  my_draw = Proc.new do
    resources :entities
    root :to => "entities#index"
  end

  if ENV['RAILS_RELATIVE_URL_ROOT']
    scope ENV['RAILS_RELATIVE_URL_ROOT'] do
      my_draw.call
    end
  else
    my_draw.call
  end
end
</pre>

## config/deploy.rb
<pre>
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
</pre>

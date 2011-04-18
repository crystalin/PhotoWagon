set :application, "photowagon"
set :repository,  "https://github.com/crystalin/PhotoWagon.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`


set :user, "crystalin"
set :scm_username, "crystalin"

set :use_sudo, false
set :deploy_to, "/var/www/rails"
set :deploy_via, :remove_cache

role :web, "japon.crystalin.fr"                          # Your HTTP server, Apache/etc
role :app, "japon.crystalin.fr"                          # This may be the same as your `Web` server
role :db,  "japon.crystalin.fr", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

after "deploy", "deploy:bundle_gems"
after "deploy:bundle_gems", "deploy:migrate"
after "deploy:migrate", "deploy:restart"
#If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :bundle_gems do
    run "cd #{deploy_to}/current && bundle install vendor/gems"
  end
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

after "deploy:update_code", :roles => [:web] do
    run "cd #{release_path} && bundle install --without development test"
end

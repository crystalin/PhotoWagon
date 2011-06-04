#Command : rvm ruby cap deploy

$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.

set :whenever_command, 'rvm ruby whenever'

set :rvm_ruby_string, '1.9.2-p180@photowagon'        # Or whatever env you want it to run in.
#set :rvm_type, :user

set :application, "photowagon"
set :repository,  "https://github.com/crystalin/PhotoWagon.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`


set :user, "crystalin"
set :scm_username, "crystalin"

set :use_sudo, false
set :deploy_to, "/var/www/rails/photowagon"

role :web, "japon.crystalin.fr"                          # Your HTTP server, Apache/etc
role :app, "japon.crystalin.fr"                          # This may be the same as your `Web` server
role :db,  "japon.crystalin.fr", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# add these to your deploy.rb

require "rvm/capistrano"                  # Load RVM's capistrano plugin.
require "whenever/capistrano"


#If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :create_gemset, :roles => :app do
    run "rvm use ruby-#{rvm_ruby_string} --create"
  end
  task :bundle_gems, :roles => :app do
    run "cd #{release_path} && bundle install --without development test && rvm rvmrc trust"
  end
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end



namespace :assets  do
  namespace :symlinks do
    desc "Setup application symlinks for shared assets"
    task :setup, :roles => [:app, :web] do
      shared_assets.each { |link| run "mkdir -p #{shared_path}/#{link}" }
    end

    desc "Link assets for current deploy to the shared location"
    task :update, :roles => [:app, :web] do
      shared_assets.each { |link| run "ln -nfs #{shared_path}/#{link} #{release_path}/#{link}" }
    end
  end
end

set :shared_assets, %w{public/uploads}

namespace :deploy do

  desc "Install gem Whenever"
  task :install_whenever do
    run "rvm gem install i18n whenever"
  end

  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    template = ERB.new IO.read('backup.rb.erb')
    File.open('backup.rb', 'w') {|f| f.write(template.result(binding))}
    run "cd #{release_path} && rvm ruby whenever --update-crontab #{application}"
  end
end

before "deploy", "deploy:create_gemset"
after "deploy:create_gemset", "deploy:install_whenever"
before "deploy:setup", "assets:symlinks:setup"
before "deploy:symlink", "assets:symlinks:update"
after "deploy", "deploy:bundle_gems"
after "deploy:bundle_gems", "deploy:update_crontab"
after "deploy:update_crontab", "deploy:migrate"
after "deploy:migrate", "deploy:restart"
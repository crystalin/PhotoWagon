#Command : rvm ruby cap deploy
set :stages,                %w(production staging)
set :default_stage,         "staging"
set :capistrano_extensions, [:multistage, :git, :mysql, :rails, :unicorn, :servers]

$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                                # Load RVM's capistrano plugin.
require "bundler/capistrano"
require "whenever/capistrano"
require 'capistrano/ext/multistage'

###### Can Be Changed #######
set :application,     "photowagon"
set :shared_assets,   %w{public/uploads}

set :ssh_options, { :forward_agent => true, :keys_only => false, :paranoid => false, :verbose => Logger::DEBUG  }
set :keys_only, true

depend :local, :command, "git"
depend :local, :command, "mysqld" #mysqld
depend :local, :command, "identify"
depend :local, :command, "exiftool" #libimage-exiftool-perl
#############################

set :user, "deployer"
set :group, "staff"
#set :scm_username, "crystalin"

set :scm,             :git
set :rvm_type,        :user
set :migrate_target,  :current
set :use_sudo,        false

set :repository,  "https://github.com/crystalin/PhotoWagon.git"
set :deploy_to,       "/home/deployer/apps/#{application}"

set :pre_gems,        %w[bundler i18n whenever]

depend :local, :command, "git"
depend :local, :command, "mysqld"
depend :local, :command, "identify"

set(:latest_release)  { fetch(:current_path) }
set(:release_path)    { fetch(:current_path) }
set(:current_release) { fetch(:current_path) }

set(:current_revision)  { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:latest_revision)   { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:previous_revision) { capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip }

# Use our ruby-1.9.2-p290@my_site gemset
default_environment["PATH"]         = "/usr/local/rvm/gems/ruby-1.9.2-p290@#{application}/bin:/usr/local/rvm/rubies/ruby-1.9.2-p290/bin:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/home/deployer/.rvm/bin"
default_environment["GEM_HOME"]     = "/usr/local/rvm/gems/ruby-1.9.2-p290@#{application}"
default_environment["GEM_PATH"]     = "/usr/local/rvm/gems/ruby-1.9.2-p290@#{application}"
default_environment["RUBY_VERSION"] = "ruby-1.9.2-p290@#{application}"

default_run_options[:shell] = '/bin/bash'

set :unicorn_binary, "unicorn_rails"
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

task :uname do
  run "uname -a"
end


namespace :deploy do

  desc "Executes the initial procedures for deploying a Ruby on Rails Application."
  task :initial do
    before "deploy:migrate", "db:create"
    setup
    update
    start
  end

  desc "Deploying without nginx previously running"
  task :cold do
    update
    start
  end

  desc "Setup your git-based deployment app"
  task :setup, :except => { :no_release => true } do
    dirs = [deploy_to, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d) }
    run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
    run "git clone #{repository} #{current_path}"
  end

  task :symlink, :except => { :no_release => true } do
  end

  desc "Update the deployed code."
  task :update_code, :except => { :no_release => true } do
    run "cd #{current_path}; git fetch origin; git reset --hard origin/master"
    finalize_update
  end

  desc "Zero-downtime restart of Unicorn"
  task :restart, :except => { :no_release => true } do
    run "kill -s USR2 `cat  #{unicorn_pid}`"
  end

  desc "Start unicorn"
  task :start, :except => { :no_release => true } do
    run "cd #{current_path} ; bundle exec unicorn_rails -c #{unicorn_config} -D"
  end

  desc "Stop unicorn"
  task :stop, :except => { :no_release => true } do
    run "kill -s QUIT `cat  #{unicorn_pid}`"
  end

  namespace :rollback do
    desc "Moves the repo back to the previous version of HEAD"
    task :repo, :except => { :no_release => true } do
      set :branch, "HEAD@{1}"
      deploy.default
    end

    desc "Rewrite reflog so HEAD@{1} will continue to point to at the next previous release."
    task :cleanup, :except => { :no_release => true } do
      run "cd #{current_path}; git reflog delete --rewrite HEAD@{1}; git reflog delete --rewrite HEAD@{1}"
    end

    desc "Rolls back to the previously deployed version."
    task :default do
      rollback.repo
      rollback.cleanup
    end
  end
end

def run_rake(cmd)
  run "cd #{current_path}; #{rake} #{cmd}"
end

namespace :db do
  desc "Create the database"
  task :create, :roles => :db, :only => { :primary => true } do
    migrate_env = fetch(:migrate_env, "")
    migrate_target = fetch(:migrate_target, :latest)

    directory = case migrate_target.to_sym
      when :current then current_path
      when :latest  then latest_release
      else raise ArgumentError, "unknown migration target #{migrate_target.inspect}"
      end

    run "cd #{directory} && #{rake} RAILS_ENV=#{rails_env} #{migrate_env} db:create"
  end
end

namespace :rails do
  task :chmod_rails do
    run "cd #{current_path} && chmod u+x script/rails"
  end
end

namespace :backup do
  desc "Install the ssh keys for backup"
  task :setup_backup do
    #removed for safety
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
      shared_assets.each { |link| run "ln -nfs #{shared_path}/#{link} #{current_path}/#{link}" }
    end
  end

  desc "Compile all the assets named in config.assets.precompile."
  task :precompile_assets do
    run_rake "assets:precompile"
  end
end

namespace :gems do
  desc "Install prerequired gems Whenever i18n bundler"
  task :install_pre_gems do
    run "gem list --local #{pre_gems.join(' ')} | wc -l | grep #{pre_gems.count} || gem install #{pre_gems.join(' ')} --no-ri --no-rdoc"
  end
end

namespace :sitemap do
  desc "Generate the sitemap"
  task :generate_sitemap do
    run_rake "sitemap:refresh"
  end
end

namespace :nginx do
  desc "Generate nginx configuration"
  task :generate_site, :roles => :web, :except => { :no_release => true } do
    require 'erb'

    template = File.read(File.join(File.dirname(__FILE__), "deploy", "#{application}.nginx.conf.erb"))
    result = ERB.new(template).result(binding)

    put result, "#{current_path}/config/deploy/#{domain.split(' ').first}", :mode => 0644
  end

end

namespace :cache do
  desc "Flush the cache"
  task :flush, :roles => :web, :except => { :no_release => true } do
    run " cd #{current_path} && script/rails runner Sweeper.sweep_all"
  end
end


after "deploy:setup",             "backup:setup_backup"
after "deploy:setup",             "gems:install_pre_gems"

before "deploy:migrate",          "bundle:install"
before "deploy:finalize_update",  "deploy:migrate"
#before "deploy:finalize_update",  "cache:flush"

after "deploy:finalize_update",   "assets:symlinks:setup"
after "deploy:finalize_update",   "assets:symlinks:update"

#before "deploy:finalize_update", "deploy:migrate"
after "deploy:finalize_update",   "sitemap:generate_sitemap"
after "deploy:finalize_update",   "assets:precompile_assets"
after "deploy:finalize_update",   "nginx:generate_site"
after "deploy:finalize_update",   "rails:chmod_rails"

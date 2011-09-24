server 'japon.crystalin.fr', :app, :web, :db, :primary => true
set :domain, "japon.crystalin.fr dubai.crystalin.fr"
set :rails_env, "production"
set :backup_server, "backup.crystalin.fr"

##If you are using Passenger mod_rails uncomment this:
#namespace :deploy do
#  task :start do end
#  task :stop do end
#  task :restart, :roles => :app, :except => { :no_release => true } do
#    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#  end
#end
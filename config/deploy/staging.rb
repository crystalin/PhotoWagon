server '192.168.1.18', :app, :web, :db, :primary => true
set :domain, "photostage.com"
set :rails_env, "staging"
set :backup_server, "192.168.1.4"
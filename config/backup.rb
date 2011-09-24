database_yml = File.expand_path('../config/database.yml',  __FILE__)
RAILS_ENV = ENV['RAILS_ENV'] || 'development'
RAILS_DIR = File.expand_path('..',  __FILE__)

require 'yaml'
config = YAML.load_file(database_yml)[RAILS_ENV]

if RAILS_ENV == "production"
  server_ip = "backup.crystalin.fr"
else
  server_ip = "192.168.1.4"
end


Backup::Model.new(:db_backup, 'PhotoWagon default backup configuration') do

  database MySQL do |database|
    database.name               = config['database']
    database.username           = config['username']
    database.password           = config['password']
    database.additional_options = ['--single-transaction', '--quick']
  end

  archive :shared_assets do |archive|
    shared_folder = "#{RAILS_DIR}/../../shared"
    shared_folder = "#{RAILS_DIR}/../shared" if not File.exists? "#{RAILS_DIR}/../../shared"
    archive.add shared_folder
  end

  compress_with Gzip do |compression|
    compression.best = true
  end

  store_with SFTP do |server|
    server.username = 'backup-photowagon'
    server.ip       = server_ip
    server.port     = 22
    server.path     = "./backup-#{RAILS_ENV}"
    server.keep     = 5
  end

end

@db_config = YAML.load_file("database")["production"]

Backup::Model.new(:photowagon_backup, 'Photowagon default backup configuration') do

  database MySQL do |database|
    database.name               = @db_config['database']
    database.username           = @db_config['username']
    database.password           = @db_config['password']
    database.skip_tables        = []
    database.additional_options = ['--single-transaction', '--quick']
  end

  archive :shared_assets do |archive|
    archive.add  "/var/www/rails/photowagon/shared"
  end

  encrypt_with OpenSSL do |encryption|
    encryption.password = 'GRj45kqpz23!!F2'
  end


  store_with S3 do |s3|
    s3.access_key_id      = 'my_access_key_id'
    s3.secret_access_key  = 'my_secret_access_key'
    s3.region             = 'us-east-1'
    s3.bucket             = 'my_bucket/backups'
    s3.keep               = 20
  end

  sync_with S3 do |s3|
    s3.access_key_id     = "my_access_key_id"
    s3.secret_access_key = "my_secret_access_key"
    s3.bucket            = "my-bucket"
    s3.path              = "/backups"
    s3.mirror            = true

    s3.directories do |directory|
      directory.add "/var/apps/my_app/public/videos"
      directory.add "/var/apps/my_app/public/music"
    end
  end

  notify_by Mail do |mail|
    mail.on_success = false
    mail.on_failure = true
  end

  notify_by Twitter do |tweet|
    tweet.on_success = true
    tweet.on_failure = true
  end

end
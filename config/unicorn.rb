# config/unicorn.rb
# Set environment to development unless something else is specified
rails_env = ENV["RAILS_ENV"] || "development"

# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.

application = "photowagon"

# Production specific settings
if rails_env == "production" or rails_env == "staging"

  user 'deployer', 'staff'
  application_path =  "/home/deployer/apps/#{application}"
  current_path =  "#{application_path}/current"
  preload_app true
  timeout 30
  worker_processes 2


  shared_path = "#{application_path}/shared"

  stderr_path "#{shared_path}/log/unicorn.stderr.log"
  stdout_path "#{shared_path}/log/unicorn.stdout.log"
  pid_path = "#{current_path}/tmp/pids"

else
  user 'crystalin', 'sysadmin'
  application_path =  "/media/sf_Projects/photowagon"
  current_path =  application_path

  timeout 90
  worker_processes 2

  stderr_path "#{current_path}/log/unicorn.stderr.log"
  stdout_path "#{current_path}/log/unicorn.stdout.log"
  pid_path = "/tmp/#{application}/pids"

  Dir.mkdir(pid_path) if not File.exists? pid_path

end


working_directory "#{current_path}/"
listen "/tmp/#{application}.socket", :backlog => 64
pid "#{pid_path}/unicorn.pid"

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "#{pid_path}/unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  # the following is *required* for Rails + "preload_app true",
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end
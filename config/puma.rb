# frozen_string_literal: true

# if ENV['RAILS_ENV'] == 'production'

  # First, you need to change these below to your situation.
  APP_ROOT = '/app'
  socket_dir = "#{APP_ROOT}/tmp/sockets"
  log_dir = "#{APP_ROOT}/tmp/log"
  pids_dir = "#{APP_ROOT}/tmp/pids"
  [socket_dir, log_dir, pids_dir].each do |dir|
    Dir.mkdir(dir) unless Dir.exist?(dir)
  end

  num_workers = ENV["NUM_WEBS"].to_i > 0 ? ENV["NUM_WEBS"].to_i : 4

  # Second, you can choose how many threads that you are going to run at same time.
  workers "#{num_workers}"
  threads 8, 32

  port ENV.fetch("PORT") { 3000 }

  # Unless you know what you are changing, do not change them.
  bind "unix://#{APP_ROOT}/tmp/sockets/puma.sock"
  stdout_redirect "#{APP_ROOT}/log/puma.log", "#{APP_ROOT}/log/puma.err.log"
  pidfile "#{APP_ROOT}/tmp/pids/puma.pid"
  state_path "#{APP_ROOT}/tmp/pids/puma.state"
  preload_app!

  # Allow puma to be restarted by `rails restart` command.
  plugin :tmp_restart

# end

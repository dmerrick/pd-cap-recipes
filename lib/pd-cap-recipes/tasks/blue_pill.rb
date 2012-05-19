Capistrano::Configuration.instance(:must_exist).load do |config|
  namespace :bluepill do
    desc "Stop processes that bluepill is monitoring and quit bluepill"
    task :quit, :roles => [:bg_task] do
      bluepill_exec "stop"
      bluepill_exec "quit"
    end

    desc "Load bluepill configuration and start it"
    task :start, :roles => [:bg_task] do
      bluepill_exec "load #{bluepill_path}", :no_error => false
    end

    desc "Restart bluepill"
    task :restart, :roles => [:bg_task] do
      bluepill_exec "restart"
    end

    desc "Stop then start bluepill"
    task :rolling_stop_start, :roles => [:bg_task] do
      servers = find_servers_for_task(current_task)
      num_partitions = (servers.size/3.0).ceil
      partitions = num_partitions > 0 ? servers.enum_slice(num_partitions) : []
      time_started = Time.now
      partitions.each do |hosts|
        bluepill_exec "stop", :hosts => hosts
        bluepill_exec "quit", :hosts => hosts
        bluepill_exec "load #{bluepill_path}", :hosts => hosts, :no_error => false

        # Wait for bluepill to start the workers
        while !rolling_timeout?(time_started) && !bluepill_started?(hosts)
          puts "Workers not started"
          sleep 5
        end
      end
    end

    desc "Prints bluepills monitored processes statuses"
    task :status, :roles => [:bg_task] do
      bluepill_exec "status"
    end
  end

  def bundle_exec(cmd, options = {})
    options = options.clone
    to_run = "sh -c \"cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec #{cmd}\""
    to_run << ' || true' if options.delete(:no_error)
    output = ""
    append_to_output = lambda do |channel, stream, data|
      level = stream == :err ? :important : :info
      logger.send(level, data, "#{stream} :: #{channel[:server]}")
      output << data 
    end

    if options.delete(:sudo)
      sudo to_run, options, &append_to_output
    else
      run to_run, options, &append_to_output
    end
    output
  end

  def bluepill_exec(cmd, options = {})
    bundle_exec "bluepill #{cmd}", {:sudo => true, :no_error => true}.merge(options)
  end

  def bluepill_path
    File.join(current_path, 'config', 'bluepill.pill')
  end

  def bluepill_started?(hosts)
    # Command to check that a process is running. Should be somethink like:
    # ps ax | grep 'my_worker\s*$' | wc -l 
    cmd = fetch(:bluepill_started_cmd, 'true')
    workers = capture(cmd, :hosts => hosts)
    workers.to_i > 0
  end

  def rolling_timeout?(time_started)
    time_started + 2.minutes < Time.now 
  end

end

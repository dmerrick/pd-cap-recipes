# adapted from CapistranoBoss  https://github.com/ascarter/capistrano-boss/
#
require File.join(File.dirname(__FILE__), "cap_ext", "log.rb")

module CapistranoBoss
  # Standardized timestamp
  # Example:
  #   200912241432
  def self.timestamp
    Time.now.strftime("%Y%m%d%H%M")
  end
end

include CapistranoBoss
include CapistranoBoss::Log

Capistrano::Configuration.instance(:must_exist).load do |config|
  namespace :log do
    namespace :rails do
      desc "Download Rails application log"
      task :fetch, :roles => :app do
        source = "#{shared_path}/log/#{rails_env}.log"
        dest = ENV['destination'] || File.join('log', 'deploy')
        fetch_log source, dest
      end

      desc "Download day old Rails application log"
      task :fetch_old, :roles => :app do
        source = "#{shared_path}/log/#{rails_env}.log.1"
        dest = ENV['destination'] || File.join('log', 'deploy')
        fetch_log source, dest
      end

    end #namespace rails

    namespace :bg_task do
      desc "Download bg_task log"
      task :fetch, :roles => :bg_task do
        source = "#{shared_path}/log/bg_task/bg_task_runner.output"
        dest = ENV['destination'] || File.join('log', 'deploy')
        fetch_log source, dest
      end

      desc "Download day old bg_task log"
      task :fetch_old, :roles => :bg_task do
        source = "#{shared_path}/log/bg_task/bg_task_runner.output.1"
        dest = ENV['destination'] || File.join('log', 'deploy')
        fetch_log source, dest
      end
    end

    namespace :db_queue do
      desc "Download db_queue log"
      task :fetch, :roles => :bg_task do
        source = "#{shared_path}/log/db_queue_worker/db_queue_worker.output"
        dest = ENV['destination'] || File.join('log', 'deploy')
        fetch_log source, dest
      end

      desc "Download day old db queue log"
      task :fetch_old, :roles => :bg_task do
        source = "#{shared_path}/log/db_queue_worker/db_queue_worker.output.1"
        dest = ENV['destination'] || File.join('log', 'deploy')
        fetch_log source, dest
      end
    end

  end
end

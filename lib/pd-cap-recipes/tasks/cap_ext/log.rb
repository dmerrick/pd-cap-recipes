# https://github.com/ascarter/capistrano-boss/

require 'fileutils'

module CapistranoBoss
  module Log
    def source_logs(input)
      input.is_a?(Array) ? input : [ input ]
    end

    # Download log to destination/<timestamp>
    def fetch_log(input, destination = ".")
      target_dir = File.join(destination, rails_env, CapistranoBoss::timestamp)
      FileUtils.mkdir_p(target_dir)
      source_logs(input).each do |s|
        download s, "#{target_dir}/$CAPISTRANO:HOST$-#{File.basename(s)}"
      end
    end
    
    # Pretty print a stats hash.
    # Expects::
    #  { "host" => { "key1" => value, "key2" => value } }
    def dump_stats(stats)
      stats.each do |host, values|
        puts "-" * 40
        puts "#{host}"
        puts "-" * 40
        values.sort.each {|k,v| puts "  #{k} => #{v}" }
      end
    end    
  end
end


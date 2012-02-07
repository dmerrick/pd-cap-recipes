Capistrano::Configuration.instance(:must_exist).load do |config|
  namespace :nginx do
    Array(fetch(:nginx_roles, :app)).each do |role|
      namespace role do
        %w(start stop reload restart).each do |action|
          desc "#{action} Nginx"
          task action.to_sym, :roles => role do
            # Use nohup because otherwise nginx dies when the connection is severed 
            sudo "nohup /etc/init.d/nginx #{action}"
          end
        end

        desc 'Backup nginx config'
        task :backup, :roles => role do
          run "mkdir -p /u/apps/pagerduty/backups"
          run "cp /opt/nginx/conf/nginx.conf /u/apps/pagerduty/backups/#{Time.now.strftime("%d%m%Y")}-nginx.conf.bak"
        end

        config_path = File.join(File.dirname(__FILE__), "..", "nginx_#{role}.conf")
        desc "Update Nginx config with the local copy located at #{config_path}"
        task :update_config, :roles => role do
          tmp = '/tmp/nginx.conf'
          upload config_path, tmp, :via => :scp
          sudo "cp #{tmp} /opt/nginx/conf/nginx.conf"
        end
      end
    end
  end
end

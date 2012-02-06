Capistrano::Configuration.instance(:must_exist).load do |config|
  namespace :nginx do

    # For now, allow config file actions only on the Linode hosts.
    # NGInx installations on EC2 are Chef managed.  To see the
    # config file there, check the Chef repo.

    namespace :linode do
      desc 'Backup nginx config'
      task :backup, :roles => :linode do
        run "mkdir -p /u/apps/pagerduty/backups"
        run "cp /opt/nginx/conf/nginx.conf /u/apps/pagerduty/backups/#{Time.now.strftime("%d%m%Y")}-nginx.conf.bak"
      end

      config_path = File.join(File.dirname(__FILE__), "..", "nginx_linode.conf")
      desc "Update Nginx config with the local copy located at #{config_path}"
      task :update_config, :roles => :linode do
        tmp = '/tmp/nginx.conf'
        upload config_path, tmp, :via => :scp
        sudo "cp #{tmp} /opt/nginx/conf/nginx.conf"
      end
    end
 
    [:ec2, :linode, :app].each do |role|
      ns = role == :app ? :all : role
      namespace ns do
        %w(start stop reload restart).each do |action|
          desc "#{action} Nginx"
          task action.to_sym, :roles => role do
            # Use nohup because otherwise nginx dies when the connection is severed 
            sudo "nohup /etc/init.d/nginx #{action}"
          end
        end
      end
    end
  end
  
end

Capistrano::Configuration.instance(:must_exist).load do |config|
  namespace :unicorn do
    [:ec2, :linode, :app].each do |role|
      ns = role == :app ? :all : role
      namespace ns do
         %w(start stop reload restart).each do |action|
          desc "#{action} Nginx"
          task action.to_sym, :roles => role, :on_error => :continue do
            # Use nohup because otherwise nginx dies when the connection is severed 
            run  "cd ${RAILS_ROOT} && RAILS_ENV=#{stage} APP=pagerduty sudo nohup /etc/init.d/unicorn #{action}"
          end
        end
      end
    end
  end
end

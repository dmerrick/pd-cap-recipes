Capistrano::Configuration.instance(:must_exist).load do |config|
  namespace :unicorn do
    Array(fetch(:unicorn_roles, :app)).each do |role|
      namespace role do
         %w(start stop reload restart).each do |action|
          desc "#{action} Unicorn"
          task action.to_sym, :roles => role, :on_error => :continue do
            # Use nohup because otherwise nginx dies when the connection is severed 
            run  "cd ${RAILS_ROOT} && RAILS_ENV=#{rails_env} APP=#{application} sudo nohup /etc/init.d/#{unicorn_init_script} #{action}"
          end
        end
      end
    end
  end
end

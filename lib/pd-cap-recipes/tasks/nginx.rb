Capistrano::Configuration.instance(:must_exist).load do |config|
  namespace :nginx do
    Array(fetch(:nginx_roles, :app)).each do |role|
      namespace role do
        %w(start stop reload restart).each do |action|
          desc "#{action} Nginx"
          task action.to_sym, :roles => role do
            # Use nohup because otherwise nginx dies when the connection is severed 
            sudo "nohup sv #{action} nginx"
          end
        end
      end
    end
  end
end

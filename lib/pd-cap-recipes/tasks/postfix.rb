Capistrano::Configuration.instance(:must_exist).load do |config|
  namespace :postfix do
    %w(start stop reload).each do |action|
      desc "#{action} postfix mail server"
      task action.to_sym, :roles => :email do
        sudo "/usr/sbin/postfix #{action}"
      end
    end
  end
end

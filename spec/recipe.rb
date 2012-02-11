set :application, "pagerduty"
set :scm, :git

set :cap_gun_email_envelope, { 
  :from => "ops+deploy@pagerduty.com", 
  :recipients => %w[ops+deploy@pagerduty.com] 
}
set :nginx_roles, [:linode, :ec2, :app]
set :unicorn_roles, [:linode, :ec2, :app]

set :hipchat_token, "test_token"
set :hipchat_room_name, 'test room'

require 'pd-cap-recipes'

namespace :deploy do
  desc 'Restart the app'
  task :restart do
  end
end

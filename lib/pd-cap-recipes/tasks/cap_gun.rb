require 'cap_gun'

Capistrano::Configuration.instance(:must_exist).load do |config|
  # define the options for the actual emails that go out -- :recipients is the only required option
  set :cap_gun_email_envelope, { 
    :from => "ops+deploy@pagerduty.com", # Note, don't use the form "Someone project.deploy@example.com" as it'll blow up with ActionMailer 2.3+
    :recipients => %w[ops+deploy@pagerduty.com] 
  }

  # register email as a callback after restart
  after "deploy:restart", "cap_gun:email"

  # Test everything out by running "cap cap_gun:email"
end

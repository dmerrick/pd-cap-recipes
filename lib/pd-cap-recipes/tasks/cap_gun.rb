require 'cap_gun'

Capistrano::Configuration.instance(:must_exist).load do |config|
  # define the options for the actual emails that go out -- 
  # :recipients is the only required option
  # set :cap_gun_email_envelope, { 
  #   :from => "deploy@mydomain.com", 
  #   :recipients => %w[deploy@mydomain.com] 
  # }

  # register email as a callback after restart
  #after "deploy", "cap_gun:email"
  #after "deploy:migrations", "cap_gun:email"

  # Test everything out by running "cap cap_gun:email"
end

Capistrano::Configuration.instance(:must_exist).load do |config|
  namespace :db do 
    desc "Prompts you to continue if you have pending migrations and did not deploy with deploy:migrations"
    task 'check_for_pending_migrations' do
      if has_pending_migrations?
        unless confirm("You currently have pending migrations but are deploying without deploy:migrations. Are you sure this is what you want to do?")
          raise Capistrano::Error.new("Aborting due to pending migrations")
        end
      end
    end
  end

  def has_pending_migrations?
    !(local_migrations - server_migrations).empty?
  end

  def server_migrations
    # || true to ignore errors as the pd_db_migrations script might not be there
    # for the first deploy
    out = capture("cd #{current_path} && RAILS_ENV=#{stage} bundle exec pd_db_migrations || true")
    out.split("\n")
  end

  def local_migrations
    migrations = Dir['db/migrate/*.rb'].map do |f|
      f.match(/migrate\/(\d+)_/).to_a[1]
    end 
  end

  # Optimally, I would like a way for this to happen after deploy and
  # bundle:install, but not on deploy:migrations. Capistrano does not seem to
  # offer a way of doing that, so we might be missing a script on the server
  # the first time this gets run.
  after 'deploy', 'db:check_for_pending_migrations'
end


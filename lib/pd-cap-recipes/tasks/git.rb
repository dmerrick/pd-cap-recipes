require 'git'
require 'grit'

# Bump up grit limits since git.fetch can take a lot
Grit::Git.git_timeout = 600 # seconds
Grit::Git.git_max_size = 104857600 # 100 megs

Capistrano::Configuration.instance(:must_exist).load do |config|
  namespace :deploy do
    desc 'Cut a tag for deployment'
    task :prepare do
      git.cut_tag
    end
  end

  after "deploy:symlink", "git:update_tag_for_stage"
  #before "deploy", "git:validate_branch_is_tag"
  #before "deploy:migrations", "git:validate_branch_is_tag"

  namespace :git do

    task :cut_tag do
      repo = Grit::Repo.new('.')

      git = Grit::Git.new(File.join('.', '.git'))
      raise "You are currently in a detached head state. Cannot cut tag." if !repo.head

      git.fetch

      new_tag = "#{repo.head.name}-#{Time.now.utc.to_i}"
      git.tag({}, new_tag)
      git.push({}, 'origin', "refs/tags/#{new_tag}")

      Capistrano::CLI.ui.say "Your new tag is #{green new_tag}" 
      Capistrano::CLI.ui.say "You can deploy the tag by running:\n  bundle exec cap #{stage} deploy -s tag=#{new_tag}" 
    end

    set :branch do
      return config[:_git_branch] if config[:_git_branch]

      tag = config[:tag]
      if !config[:tag]
        tag = Capistrano::CLI.ui.ask green("Tag to deploy: ")
        tag = tag.to_s.strip
      end

      config[:_git_branch] = tag
      git_sanity_check(tag)

      config[:_git_branch]
    end

    task :update_tag_for_stage do
      git = Grit::Git.new(File.join('.', '.git'))

      # Clear previous pointer if exists. Ignore errors here.
      git.tag(:d => config[:stage])
      git.push({}, 'origin', ":refs/tags/#{config[:stage]}")

      # Set new pointer to current HEAD.
      git.tag({}, config[:stage])
      git.push({}, 'origin', "refs/tags/#{config[:stage]}")
    end

    task :validate_branch_is_tag do
      # Make sure an external recipe is not overriding the branch variable by
      # doing something like
      # set :branch, :master
      if config[:branch] != config[:_git_branch]
        raise Capistrano::Error.new("The current branch do not seems to match the cached version. Make sure you are not overriding it in your config by doing something like 'set :deploy, 'release''")
      end
    end
  end

  def git_sanity_check(tag)
    repo = Grit::Repo.new('.')
    git  = Grit::Git.new(File.join('.', '.git'))

    if repo.tags.select {|t| t.name == tag }.size == 0
      raise "Invalid tag name: #{tag}" 
    end

    tag_sha = repo.commit(tag).id
    deploy_sha = repo.head.commit.id

    if tag_sha != deploy_sha
      raise "Cannot deploy tag #{tag}. Does not match head SHA of #{deploy_sha}." + \
        " Please checkout the tag with: `git checkout #{tag}` and deploy again."
    end

    # See this article for info on how this works:
    # http://stackoverflow.com/questions/3005392/git-how-can-i-tell-if-one-commit-is-a-descendant-of-another-commit
    if ENV['REVERSE_DEPLOY_OK'].nil?
      if safe_current_revision && git.merge_base({}, deploy_sha, safe_current_revision).chomp != git.rev_parse({ :verify => true }, safe_current_revision).chomp
        unless continue_with_reverse_deploy(deploy_sha)
          raise "You are trying to deploy #{deploy_sha}, which does not contain #{safe_current_revision}," + \
            " the commit currently running.  Operation aborted for your safety." + \
            " Set REVERSE_DEPLOY_OK to override."
        end
      end
    end
  end

  def confirm(msg)
    continue = Capistrano::CLI.ui.ask msg
    continue = continue.to_s.strip
    continue.downcase == 'yes'
  end

  def continue_with_reverse_deploy(deploy_sha)
    msg = "You are trying to deploy #{deploy_sha}, which does not contain #{safe_current_revision}, the commit currently running. Are you sure you want to continue? #{green "[No|yes]"}"
    confirm msg
  end

  def green(s)
    "\e[1m\e[32m#{s}\e[0m" 
  end

  # current_revision will throw an exception if this is the first deploy...
  def safe_current_revision
    begin
      current_revision
    rescue => e
      logger.info "*" * 80
      logger.info "An exception as occured while fetching the current revision. This is to be expected if this is your first deploy to this machine. Othewise, something is broken :("
      logger.info e.inspect
      logger.info "*" * 80
      nil
    end
  end
end


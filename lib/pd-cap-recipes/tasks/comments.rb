COMMENT_FILE = "/var/tmp/cap_message.txt"

Capistrano::Configuration.instance(:must_exist).load do |config|
  # Make sure that there's a comment for this deploy
  set :comment do
    return config[:comment_value] if config[:comment_value]

    file = COMMENT_FILE 
    FileUtils.rm(file) if File.exists?(file)
    if no_comment?
      prev = safe_current_revision
      cur = fetch(:branch)
      content = 
"""

# Please provide a meaningful comment describing what you are deploying.
"""
      File.open(file, 'w') do |f|
        f.write(content)
      end

      if prev && cur
        `git log #{prev}..#{cur} --pretty="# %h: %s" >> #{file}`
      end

      system("#{ENV['EDITOR'] || 'vim'} #{file}")
      comment = File.exist?(file) ? File.open(file).read : nil

      config[:comment_value] = clean_comment(comment)
    end

    if no_comment?
      raise "You must specify a comment"
    end
    config[:comment_value]
  end

  def no_comment?
    !exists?(:comment_value) || fetch(:comment_value).nil? || fetch(:comment_value).strip == ""
  end

  def clean_comment(comment)
    comment.split("\n").reject{|line| /^\s*#.*$/ === line}.reject{|line| line.strip == ""}.join("\n")
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

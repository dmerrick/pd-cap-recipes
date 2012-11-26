Capistrano::Configuration.instance(:must_exist).load do |config|
  # add a comment to this deploy
  set :comment_text do
    return config[:comment] if config[:comment]

    if no_comment?
      logger.info "No comment provided. Provide one with '-S comment=\"comment here\"'"
      return ""
    end

    fetch(:comment).strip
  end

  def no_comment?
    !exists?(:comment) || fetch(:comment).nil? || fetch(:comment).strip == ""
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

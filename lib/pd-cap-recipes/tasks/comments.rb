Capistrano::Configuration.instance(:must_exist).load do |config|
  # add a comment to this deploy
  set :comment_text do
    if no_comment?
      logger.info "No comment provided. Provide one with '-S comment=\"comment here\"'"
    end

    fetch(:comment).strip
  end

  def no_comment?
    !exists?(:comment) || fetch(:comment).nil? || fetch(:comment).strip == ""
  end
end

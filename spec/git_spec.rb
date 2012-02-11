require 'spec_helper'

describe "Git sanity check", :recipe => true do
  it "should not ask for a tag when doing a restart" do
    @configuration.find_and_execute_task('deploy:restart')
  end
end


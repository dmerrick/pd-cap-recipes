require 'spec_helper'

describe "Commit comments", :recipe => true do
  describe "witout a current revision", :tag => true do
    before(:each) do
      config.set :current_revision, lambda { raise 'Error' }
      ENV['EDITOR'] = "echo 'Some comment' >> #{COMMENT_FILE}"
    end

    it "should get comment without exception" do
      config.comment
    end
  end
end

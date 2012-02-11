require 'spec_helper'

describe "Cap gun", :recipe => true do
  ["deploy", "deploy:migrations"].each do |task|
    it "should run after #{task}" do
      after_callbacks_for_task(task).should include('cap_gun:email')
    end
  end
end

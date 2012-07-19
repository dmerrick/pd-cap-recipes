require 'spec_helper'

describe "Bluepill spec", :recipe => true do
  it "should do a rolling restart of bluepills" do
    config.stub(:find_servers_for_task) { (0...5).to_a }
    config.should_receive(:restart_bluepill).with([0, 1])
    config.should_receive(:restart_bluepill).with([2, 3])
    config.should_receive(:restart_bluepill).with([4])
    config.stub(:bluepill_started?) { true }
    config.find_and_execute_task 'bluepill:rolling_stop_start'
  end
end

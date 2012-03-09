require 'spec_helper'

describe "Migration check", :recipe => true do
  it "should run before deploy" do
    before_callbacks_for_task('deploy').should include('db:check_for_pending_migrations')
  end

  it "should not run before deploy:migrations" do
    before_callbacks_for_task('deploy:migrations').should_not include('db:check_for_pending_migrations')
  end

  describe "task execution" do
    let(:task_lambda) { lambda { config.find_and_execute_task 'db:check_for_pending_migrations' } }

    describe "with pending migrations" do
      before(:each) do
        config.should_receive(:pending_migrations) { [1] }
      end

      it "should prompt to continue and continue on success" do
        config.should_receive(:confirm) { true } 
        task_lambda.call
      end

      it "should prompt to continue and fail on success" do
        config.should_receive(:confirm) { false } 
        task_lambda.should raise_error(Capistrano::Error)
      end
    end

    describe "without pending migrations" do
      before(:each) do
        config.should_receive(:pending_migrations) { [] }
      end

      it "should not prompt to continue and continue on success" do
        config.should_not_receive(:confirm) { true } 
        task_lambda.call
      end
    end
  end

  describe "pending_migrations" do
    before(:each) do
      config.should_receive(:server_migrations) { [1,2] }
    end

    it "should return true if local migrations exist that have not been runned on the server" do
      config.should_receive(:local_migrations) { [1,2,3] }
      config.pending_migrations.should == [3]
    end

    it "should return false if no local migrations exist that have not been runned on the server" do
      config.should_receive(:local_migrations) { [1,2] }
      config.pending_migrations.should == []
    end
  end
end


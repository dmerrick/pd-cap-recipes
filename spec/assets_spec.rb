require 'spec_helper'

describe "Asset compilation", :recipe => true, :tag => true do
  before do
    config.set :asset_env, ""
    config.set :rails_env, ""
    config.set :asset_cdn_host, ""
  end
  let(:task) {config.find_task 'deploy:assets:precompile' }
  let(:task_lambda) {lambda { config.find_and_execute_task 'deploy:assets:precompile' }}

  it "should sync assets to CDN after compile" do
    after_callbacks_for_task('deploy:assets:precompile').should include('deploy:assets:cdn_deploy')
  end

  it "should compile assets when forced to" do
    config.set(:always_compile_assets, true)
    task_lambda.call
    config.fetch(:skip_cdn_deploy).should == false
  end
end

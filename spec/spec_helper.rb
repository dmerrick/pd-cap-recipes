require 'capistrano'
require 'capistrano/cli'
require 'capistrano-spec'

module Capistrano::Spec::LoadTestRecipe
  def load_test_recipe
    @configuration = Capistrano::Configuration.new
    @configuration.load :file => File.join(File.dirname(__FILE__), 'recipe.rb')
    @configuration.extend(Capistrano::Spec::ConfigurationExtension)
  end

  def after_callbacks_for_task(task_name)
    callbacks_for_task(:after, task_name)
  end

  def before_callbacks_for_task(task_name)
    callbacks_for_task(:before, task_name)
  end

  def callbacks_for_task(before_of_after, task_name)
    task = @configuration.find_task(task_name)
    pending = Array(@configuration.callbacks[before_of_after]).select { |c| c.applies_to?(task) }
    pending.map(&:source)
  end

  def self.included(base)
    base.before(:each) do 
      load_test_recipe
    end
    base.let(:config) {@configuration}
  end
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.include Capistrano::Spec::Matchers
  config.include Capistrano::Spec::Helpers
  config.include Capistrano::Spec::LoadTestRecipe, :recipe => :true
end

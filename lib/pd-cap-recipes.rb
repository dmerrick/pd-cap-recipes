require "pd-cap-recipes/version"

Dir[File.join(File.dirname(__FILE__), 'pd-cap-recipes', 'tasks', '*.rb')].each { |lib| require lib }

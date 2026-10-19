ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# The Rails integration reads the model registry from the database when the
# table has rows. Load the bundled registry while that table is still empty so
# a test that seeds a single model row cannot hide the rest of the catalog.
RubyLLM.models

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

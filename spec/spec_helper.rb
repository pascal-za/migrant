require "bundler/setup"

require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start do
  add_filter '/spec'
  add_filter '/lib/tasks'
  add_filter '/lib/railtie'
  add_filter '/tmp'

  add_group 'Core Extensions', '/lib/migrant'
  add_group 'DSL', '/lib/datatype'
end

require "migrant"
require 'rails'

# Create a blank Rails app so Rails.root etc. works
class App < Rails::Application
  config.eager_load = false
  config.root = 'tmp'
end

GEM_ROOT = File.join(File.dirname(__FILE__), '..')
Dir[File.join(GEM_ROOT, 'spec', 'support', '*.rb')].each { |f| require f }

module DatabaseManagement
  def reset_database!
    begin
      ActiveRecord::Base.connection_pool.disconnect!
    rescue ActiveRecord::ConnectionNotEstablished
      # Already disconnected, mostly likely on startup  
    end
    
    db_config = {
      adapter: 'sqlite3',
      database: ':memory:'
    }
    
    ActiveRecord::Base.establish_connection(db_config)
    
    # Remove any migrations from previous tests
    Dir.glob(File.join(GEM_ROOT, 'tmp', 'db', 'migrate', '*')).each do |migration|
      File.unlink(migration)
    end        
  end
  
  def run_db_upgrade!
    Migrant::MigrationGenerator.new.run or raise "Failed to run migration generator"
    ActiveRecord::Tasks::DatabaseTasks.migrate
  end
end

# Database setup
log_directory = File.join(GEM_ROOT, 'log')
FileUtils.mkdir_p(log_directory)
ActiveRecord::Base.logger = Logger.new(File.join(log_directory, 'sql.log'))

Class.new.extend(DatabaseManagement).reset_database!  

# Mock some stubs on STDIN's eigenclass so we can fake user input
class << STDIN
  # Simple mock for simulating user inputs
  def _mock_responses(*responses)
    @_responses ||= []
    @_responses += responses
  end
  
  def gets
    raise "STDIN.gets() called but no mocks to return. Did you set them up with _mock_responses()?" if @_responses.blank?
    @_responses.slice!(0).tap do |response|
      STDOUT.puts "{ANSWERED WITH: #{response}}"
    end
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  
  config.include DatabaseManagement
  
  config.before :suite do
    App.initialize!
  end
end

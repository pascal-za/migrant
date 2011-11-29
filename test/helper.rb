require 'fileutils'

ENV['RAILS_ENV'] = 'test'

require 'rubygems'
require 'turn' # For nicer output
require 'test/unit'
require 'shoulda'
require 'terminal-table/import'

# Must be loaded before appropriate models so we get class method extensions
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'migrant'

class Profiler
  @@results = {}

  def self.run(name, &block)
    start = Time.now.to_f
    yield
    @@results[name] ||= {:total => 0.0, :calls => 0}
    @@results[name][:total] += Time.now.to_f - start 
    @@results[name][:calls] += 1
  end

  def self.results
    unless @@results.keys.empty?
      results = table do |t|
        t.headings = ['Name', 'Calls', 'Total (ms)', 'Average (ms)']
        @@results.collect { |name, result| [name, result[:calls], (result[:total]*1000.0).round, (result[:total] / result[:calls] * 1000.0).round] }.each { |row| t << row }
      end
      puts results
    end
  end
end

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

# Reset database
db_path = File.join(File.dirname(__FILE__), 'rails_app', 'db', 'test.sqlite3')
File.delete(db_path) if File.exists?(db_path)

# Remove migrations
Dir.glob(File.join(File.dirname(__FILE__), 'rails_app', 'db', 'migrate', '*')).each do |file|
 File.delete(file)
end

require File.join(File.dirname(__FILE__), 'rails_app', 'config', 'environment')

class Test::Unit::TestCase
end


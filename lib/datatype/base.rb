module DataType
  class Base
    # Pass the developer's ActiveRecord::Base structure and we'll
    # decide the best structure
    def initialize(options={})
      @options = options
      @value = options.delete(:value)
    end
    
    # Default is 'ye good ol varchar(255)
    def migration
      {:type => :string}.merge(@options)
    end
    
    def self.migration_data_example 
      "Some string" 
    end
  end
end

# And all the data types we offer...
require 'datatype/date'
require 'datatype/email'
require 'datatype/foreign_key'
require 'datatype/hash'
require 'datatype/name'
require 'datatype/paragraph'
require 'datatype/phone_number'
require 'datatype/polymorphic'
require 'datatype/range'
require 'datatype/sentence'
require 'datatype/string'
require 'datatype/time'

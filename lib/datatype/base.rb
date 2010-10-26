module DataType
  class Base
    attr_accessor :aliases
  
    # Pass the developer's ActiveRecord::Base structure and we'll
    # decide the best structure
    def initialize(options={})
      @options = options
      @value = options.delete(:value) || ''
      @aliases = options.delete(:was) || Array.new
    end
    
    # Default is 'ye good ol varchar(255)
    def column
      {:type => :string}.merge(@options)
    end
    
    def self.migration_data_example 
    end
  end
end

# And all the data types we offer...
require 'datatype/boolean'
require 'datatype/currency'
require 'datatype/date'
require 'datatype/email'
require 'datatype/float'
require 'datatype/foreign_key'
require 'datatype/hash'
require 'datatype/paragraph'
require 'datatype/phone_number'
require 'datatype/polymorphic'
require 'datatype/range'
require 'datatype/sentence'
require 'datatype/string'
require 'datatype/time'

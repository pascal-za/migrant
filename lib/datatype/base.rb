module DataType
  class DangerousMigration < Exception; end;

  class Base
    attr_accessor :aliases
  
    # Pass the developer's ActiveRecord::Base structure and we'll
    # decide the best structure
    def initialize(options={})
      @options = options
      @value = options.delete(:value)
      @field = options.delete(:field)
      @aliases = options.delete(:was) || Array.new
    end
    
    # Default is 'ye good ol varchar(255)
    def column
      {:type => :string}.merge(@options)
    end
    
    def mock
      @value || self.class.default_mock
    end
    
    def self.default_mock
      "Some string"
    end
    
    # Decides if and how a column will be changed
    # Provide the details of a previously column, or simply nil to create a new column
    def structure_changes_from(current_structure = nil)    
      new_structure = column
    
      if current_structure
        # General RDBMS data loss scenarios
        raise DataType::DangerousMigration if (new_structure[:type] != :text && [:string, :text].include?(current_structure[:type]) && new_structure[:type] != current_structure[:type])

        if new_structure[:limit] && current_structure[:limit].to_i != new_structure[:limit].to_i ||
           new_structure[:default] && current_structure[:default].to_s != new_structure[:default].to_s ||
           new_structure[:type] != current_structure[:type]
           column
        else
          nil # No changes
        end
      else
        column
      end
    end
    
    def self.migrant_data_type?; true; end
  end
end

# And all the data types we offer...
require 'datatype/boolean'
require 'datatype/currency'
require 'datatype/date'
require 'datatype/float'
require 'datatype/foreign_key'
require 'datatype/hash'
require 'datatype/polymorphic'
require 'datatype/range'
require 'datatype/string'
require 'datatype/symbol'
require 'datatype/time'

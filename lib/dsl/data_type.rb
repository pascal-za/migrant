require 'faker'

module DataType
  class DangerousMigration < Exception; end;

  class Base
    attr_accessor :aliases

    # Pass the developer's ActiveRecord::Base structure and we'll
    # decide the best structure
    def initialize(options={})
      @options = options
      @value = options.delete(:value)
      @example = options.delete(:example)
      @field = options.delete(:field)
      @aliases = options.delete(:was) || ::Array.new
      options[:type] = options.delete(:as) if options[:as] # Nice little DSL alias for 'type'      
    end

    # Default is 'ye good ol varchar(255)
    def column_defaults 
      { :type => :string }
    end
    
    def column
      column_defaults.merge(@options)
    end
            
    def ==(compared_column)
      # Ideally we should compare attributes, but unfortunately not all drivers report enough statistics for this
      column[:type] == compared_column[:type]
    end

    def mock      
      @value || self.class.default_mock
    end
    
    def serialized?
      false
    end

    # Default mock should be overridden in derived classes
    def self.default_mock
      short_text_mock
    end
    
    def self.long_text_mock    
      (1..3).to_a.collect { Faker::Lorem.paragraph }.join("\n")
    end
    
    def self.short_text_mock
      Faker::Lorem.sentence
    end

    # Decides if and how a column will be changed
    # Provide the details of a previously column, or simply nil to create a new column
    def structure_changes_from(current_structure = nil)
      new_structure = column
     
      if current_structure
        # General RDBMS data loss scenarios
        raise DataType::DangerousMigration if (new_structure[:type] != :text && [:string, :text].include?(current_structure[:type]) && new_structure[:type] != current_structure[:type])

        if new_structure[:limit] && current_structure[:limit].to_i != new_structure[:limit].to_i ||
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

require 'dsl/data_types/primitives'
require 'dsl/data_types/semantic'

# Add internal types used by Migrant
module DataType
  class Polymorphic < Base; end

  class ForeignKey < Fixnum
    def column
      {:type => :integer}
    end
    
    def self.default_mock
      nil # Will get overridden later by ModelExtensions
    end
  end
end

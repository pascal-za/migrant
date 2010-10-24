module DataForge
  # Converts the following DSL:
  #
  # class MyModel < ActiveRecord::Base
  #   structure do
  #     my_field DataForge::Paragraph
  #    end
  # end
  # into a schema on that model class by calling method_missing(my_field)
  # and deciding what the best schema type is for the user's requiredments
  class Schema
    def initialize(&block)
      @columns = Hash.new
      self.instance_eval(&block)
    end
    
    # This is where we decide what the best schema is based on the structure requirements
    # The output of this is essentially a formatted schema hash that is processed 
    # on each model by DataForge::MigrationGenerator
    def method_missing(*args, &block)
      args[1] ||= String.new # String is teh default 
      options = args.slice(2..-1)

      # If the provided class is in our known data types (like DataType::Date), instantiate directly
      puts args[1].to_s
      if args[1].is_a?(Class) && args[1].respond_to?(:migration_data_example)
        @columns[args.first] = args[1].new(options)
      else
        begin
        require 'asdasd'
        
        rescue LoadError
          # We don't have a matching type, throw a warning and default to string
          puts "MIGRATION WARNING: No migration implementation for class #{args[1].class.to_s} on field '#{args[0]}', defaulting to string..."
        end
      end
        
            
      puts "Wants column"+args.inspect
    end
  end
end

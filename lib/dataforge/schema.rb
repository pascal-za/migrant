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
    
    def migrations
      @columns.collect {|field, data| [field, data.migration] } # All that needs to be migrated
    end
    
    # This is where we decide what the best schema is based on the structure requirements
    # The output of this is essentially a formatted schema hash that is processed 
    # on each model by DataForge::MigrationGenerator
    def method_missing(*args, &block)
      args[1] ||= String.new # String is teh default 
      options = args.slice(2..-1)

      # Matches: description DataType::Paragraph, :index => true
      if args[1].is_a?(Class) && args[1].respond_to?(:migration_data_example)
        @columns[args.first] = args[1].new(options)
      # Matches: description :index => true, :unique => true
      elsif args[1].is_a?(Hash)
        @columns[args.first] = DataType::Base.new(args[1])
      # Matches: description "my description"
      else
        begin
          # Eg. "My field" -> String -> DataType::String
          @columns[args.first] = "DataType::#{args[1].class.to_s}".constantize.new(options)
        rescue NameError
          # We don't have a matching type, throw a warning and default to string
          puts "MIGRATION WARNING: No migration implementation for class #{args[1].class.to_s} on field '#{args[0]}', defaulting to string..."
          @columns[args.first] = DataType::Base.new(options)
        end
      end
      puts [":#{args.first}", "#{@columns[args.first].class}", "#{options.inspect}"].collect { |s| s.ljust(25) }.join if ENV['DEBUG']
    end
  end
end

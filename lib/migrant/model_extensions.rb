module Migrant
  module ModelExtensions
    attr_accessor :schema
    
    def belongs_to(*args)
      super
      create_migrant_schema
      @schema.add_association(self.reflect_on_association(args.first))
    end
        
    def create_migrant_schema
      if self.superclass == ActiveRecord::Base
       @schema ||= Schema.new
      else
        @schema ||= InheritedSchema.new(self.superclass.schema)
      end
    end
    
    def structure(type=nil, &block)
      # Using instance_*evil* to get the neater DSL on the models.
      # So, my_field in the structure block actually calls Migrant::Schema.my_field

      create_migrant_schema
      @structure_defined = true

      if self.superclass == ActiveRecord::Base
        @schema.define_structure(type, &block)
        @schema.validations.each do |field, validation_options|
          validations = (validation_options.class == Array)? validation_options : [validation_options]
          validations.each do |validation|
            validation = (validation.class == Hash)? validation : { validation => true }
            self.validates(field, validation)
          end
        end
        # Set up serialized columns as required
        @schema.columns.select do |name, column|
          if column.serialized? && !serialized_attributes.keys.include?(name.to_s)
            serialize(name, column.serialized_class_name)
          end
        end
      else
        self.superclass.structure(&block) # For STI, cascade all fields onto the parent model
      end
    end

    def structure_defined?
      @schema && @structure_defined || false
    end

    # Same as defining a structure block, but with no attributes besides
    # relationships (such as in a many-to-many)
    def no_structure
      structure {}
    end
    
    def reset_structure!
      @schema = nil
    end

    def mock(attributes={}, recursive=true)
      raise NoStructureDefined.new("In order to mock() #{self.to_s}, you need to define a Migrant structure block") unless @schema
 
      attribs = {}
      attribs.merge!(self.superclass.mock_attributes(attributes, recursive)) unless self.superclass == ActiveRecord::Base
      new attribs.merge(mock_attributes(attributes, recursive))
    end
    
    def mock_attributes(attributes={}, recursive=true)
      attribs = @schema.columns.collect { |name, data_type| [name, data_type.mock] }.flatten(1)

      # Only recurse to one level, otherwise things get way too complicated
      if recursive
        attribs += self.reflect_on_all_associations(:belongs_to).collect do |association|
                    begin
                      (association.klass.respond_to?(:mock))? [association.name, association.klass.mock({}, false)] : nil
                    rescue NameError; nil; end # User hasn't defined association, just skip it
                   end.compact.flatten
      end
      Hash[*attribs].merge(attributes)
    end
    
    def mock!(attributes={}, recursive=true)
      mock(attributes, recursive).tap do |mock|
        mock.save!
      end
    end
  end

  class NoStructureDefined < Exception; end;
end


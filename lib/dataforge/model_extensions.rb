module DataForge
  module ModelExtensions
    attr_accessor :schema
    def structure(&block)
      # Using instance_*evil* to get the neater DSL on the models.
      # So, my_field in the structure block actually calls DataForge::Schema.my_field
      @schema = Schema.new(self.reflect_on_all_associations, &block)
    end
    
    # Same as defining a structure block, but with no attributes besides
    # relationships (such as in a many-to-many)
    def no_structure
      @schema = Schema.new(self.reflect_on_all_associations)
    end
  end
end

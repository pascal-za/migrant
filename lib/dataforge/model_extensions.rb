module DataForge
  module ModelExtensions
    def structure(&block)
      # Using instance_*evil* to get the neater DSL on the models.
      # So, my_field in the structure block actually calls DataForge::Schema.my_field
      @@schema = Schema.new(&block)
    end
  end
end

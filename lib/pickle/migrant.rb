module Pickle
  class Migrant < Adapter
    def self.factories
      model_classes.select { |model| model.respond_to?(:mock) }.collect { |model| new(model) }
    end
    
    def initialize(klass)
      @klass, @name = klass, klass.name.underscore.gsub('/', '_')
    end
    
    def create(attrs={})
      @klass.mock!(Hash[attrs.collect { |k,v| [k.to_sym, v] }])    
    end
  end
end


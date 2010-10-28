module DataType
  class Range < Base
    def column
      definition = {:type => :integer}
      definition[:limit] = @value.max.to_s.length if @value.respond_to?(:max)
      definition
    end
    
    def self.default_mock
      0..100
    end
  end
end

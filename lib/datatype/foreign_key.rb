module DataType
  class ForeignKey < Base
    def column
      {:type => :integer}
    end
    
    def self.default_mock
      nil # Will get overridden later by ModelExtensions
    end
  end
end
  


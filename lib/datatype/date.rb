module DataType
  class Date < Base
    def column
      {:type => :datetime}
    end
    
    def self.default_mock
      ::Time.now
    end
  end
end
  


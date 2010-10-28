module DataType
  class Float < Base
    def column
      {:type => :float}
    end
    
    def self.default_mock
      rand(100).to_f-55.0
    end
  end
end

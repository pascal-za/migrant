module DataType
  class TrueClass < Base
    def column
      {:type => :boolean}
    end  
    
    def self.default_mock
      true
    end
  end
  
  class FalseClass < TrueClass; end;
end
  


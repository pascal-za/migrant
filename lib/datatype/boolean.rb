module DataType
  class TrueClass < Base
    def column
      {:type => :boolean}
    end  
  end
  
  class FalseClass < TrueClass; end;
end
  


module DataType
  class TrueClass < Base
    def migration
      {:type => :boolean}
    end  
  end
  
  class FalseClass < TrueClass; end;
end
  


module DataType
  class Symbol < Base
    def column
      # Just construct whatever the user wants
      {:type => @value || :string }.merge(@options)
    end  
  end
end
  


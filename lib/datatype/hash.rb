module DataType
  class Hash < Base
    def column
      @options = @value # Assign developer's options verbatim
        super
    end
  end
end
  


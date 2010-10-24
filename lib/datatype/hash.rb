module DataType
  class Hash < Base
    def migration
      @options = @value # Assign developer's options verbatim
        super
    end
  end
end
  


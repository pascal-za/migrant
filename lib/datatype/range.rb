module DataType
  class Range < Base
    def migration
      if @value.respond_to?(:max)
        {:type => :integer, :limit => @value.max.to_s.length}
      else 
        {:type => :integer}
      end
    end
  end
end

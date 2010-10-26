module DataType
  class Range < Base
    def column
      {:type => :integer, :limit => @value.max.to_s.length}
    end
  end
end

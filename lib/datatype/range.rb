module DataType
  class Range < Base
    def migration
      {:type => :integer, :limit => @value.max.to_s.length}
    end
  end
end

module DataType
  class Float < Base
    def column
      {:type => :double}
    end
  end
end

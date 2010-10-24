module DataType
  class Float < Base
    def migration
      {:type => :double}
    end
  end
end

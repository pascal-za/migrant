module DataType
  class Currency < Base
    def column
      {:type => :decimal, :precision => 10, :scale => 2}
    end
  end
end

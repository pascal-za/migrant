module DataType
  class Currency < Base
    def migration
      {:type => :decimal, :precision => 10, :scale => 2}
    end
  end
end

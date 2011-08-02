module DataType
  class Currency < Base
    def column_defaults
      {:type => :decimal, :precision => 10, :scale => 2}
    end
   
    def self.default_mock
      rand(9999999).to_f+0.51
    end
  end
end

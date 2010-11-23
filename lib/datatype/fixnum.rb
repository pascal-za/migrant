module DataType
  class Fixnum < Base
    def column
      {:type => :integer}
    end
  end
end

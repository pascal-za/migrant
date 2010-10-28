module DataType
  class Polymorphic < Base
    def mock
      # Eek, can't mock an unknown type
      nil
    end
  end
end

module DataType
  class Fixnum < Base
    def column
      {:type => :integer}
    end
    
    def self.default_mock
      rand(999999).to_i
    end
  end
end

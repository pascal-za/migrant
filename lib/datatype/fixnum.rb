module DataType
  class Fixnum < Base
    def column
      {:type => :integer}.tap do |options|
        options.merge!(:limit => @value.size) if @value > 2147483647 # 32-bit limit. Not checking size here because a 64-bit OS always has at least 8 byte size
      end
    end
    
    def self.default_mock
      rand(999999).to_i
    end
  end
end

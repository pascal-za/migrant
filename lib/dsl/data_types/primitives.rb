module DataType
  # Boolean
  class TrueClass < Base
    def column
      {:type => :boolean}
    end  
    
    def mock
      self.class.default_mock
    end

    def self.default_mock
      true
    end
  end
  
  class FalseClass < TrueClass
    def self.default_mock
      false
    end
  end
  
  # Datetime
  class Date < Base
    def column
      {:type => :datetime}
    end
    
    def self.default_mock
      ::Time.now
    end
  end
  
  class Time < Date; end;  # No different to date type

  # Integers
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
  
  class Bignum < Fixnum
    def column
      {:type => :integer, :limit => ((@value.size > 8)? @value.size : 8) }
    end
  end
  
  class Float < Base
    def column
      {:type => :float}
    end
    
    def self.default_mock
      rand(100).to_f-55.0
    end
  end
  
  # Range (0..10)
  class Range < Base
    def column
      definition = {:type => :integer}
      definition[:limit] = @value.max.to_s.length if @value.respond_to?(:max)
      definition
    end
  end
  
  # Strings
  class String < Base
    def initialize(options)
      super(options)
      @value ||= ''
    end
  
    def column
      if @value.match(/[\d,]+\.\d{2}$/)
        return Currency.new(@options).column
      else
        return @value.match(/[\r\n\t]/)? { :type => :text }.merge(@options) : super
      end
    end
    
    def mock
      @value || ((self.column[:type] == :text)? self.class.long_text_mock : self.class.default_mock )
    end
  end
  
  # Symbol (defaults, specified by user)
  class Symbol < Base
    def column
      # Just construct whatever the user wants
      {:type => @value || :string }.merge(@options)
    end  
    
    def mock
      case @value || :string
        when :text then self.class.long_text_mock
        when :string then self.class.short_text_mock
        when :integer then Fixnum.default_mock
        when :decimal, :float then Float.default_mock
        when :datetime, :date then Date.default_mock
      end
    end
  end
  
end
  


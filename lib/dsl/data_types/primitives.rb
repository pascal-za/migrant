module DataType
  # Boolean
  class TrueClass < Base
    def column_defaults
      {:type => :boolean}
    end  
    
    def mock
      self.class.default_mock
    end

    def self.default_mock
      true
    end
    
    def column_default_changed?(old_default, new_default)
      old_default.to_s[0] != new_default.to_s[0]
    end
  end
  
  class FalseClass < TrueClass
    def self.default_mock
      false
    end

    def column_default_changed?(old_default, new_default)
      old_default.to_s[0] != new_default.to_s[0]
    end
  end
  
  # Datetime
  class Date < Base
    def column_defaults
      {:type => :date}
    end
    
    def self.default_mock
      ::Date.today
    end
  end
  
  class Time < Date 
    def column_defaults
      {:type => :datetime}
    end
    
    def self.default_mock
      ::Time.now
    end
  end

  # Integers
  class Fixnum < Base
    def column_defaults
      {:type => :integer}.tap do |options|
        options.merge!(:limit => @value.size) if @value > 2147483647 # 32-bit limit. Not checking size here because a 64-bit OS always has at least 8 byte size
      end
    end
    
    def self.default_mock
      rand(999999).to_i
    end
  end  
  
  class Bignum < Fixnum
    def column_defaults
      {:type => :integer, :limit => ((@value.size > 8)? @value.size : 8) }
    end
  end
  
  class Integer < Bignum
  end
  
  class Float < Base
    def column_defaults
      {:type => :float}
    end
    
    def self.default_mock
      rand(100).to_f-55.0
    end
  end
  
  # Range (0..10)
  class Range < Base
    def column_defaults
      definition = {:type => :integer}
      definition
    end
  end
  
  # Strings
  class String < Base
    def initialize(options)
      super(options)
      @value ||= ''
    end
  
    def column_defaults
      if @value.match(/[\d,]+\.\d{2}$/)
        return Currency.new(@options).column_defaults
      else
        return @value.match(/[\r\n\t]/)? { :type => :text }.merge(@options) : super
      end
    end
    
    def mock
      @value || ((self.column_defaults[:type] == :text)? self.class.long_text_mock : self.class.default_mock )
    end
  end
  
  # Symbol (defaults, specified by user)
  class Symbol < Base
    def column_defaults
      # Just construct whatever the user wants
      {:type => ((serialized?)? :text : @value) || :string }.merge(@options)
    end  
    
    def mock
      case @value || :string
        when :text then self.class.long_text_mock
        when :string then self.class.short_text_mock
        when :integer then Fixnum.default_mock
        when :decimal, :float then Float.default_mock
        when :datetime, :date then Date.default_mock
        when :serialized, :serialize then (@example)? @example : Hash.default_mock
      end
    end
    
    def serialized?
      %W{serialized serialize}.include?(@value.to_s)
    end
    
    def serialized_class_name
      klass_name = (@example)? @example.class.to_s : "Hash"      
      
      klass_name.constantize
    end
  end
  
  # Objects
  class Object < Base
    def column_defaults
      {:type => :text }
    end
    
    def self.default_mock     
      self.native_class.new
    end
    
    def mock
      @value || self.default_mock
    end
    
    def serialized?
      true
    end
    
    def serialized_class_name
      self.class.native_class
    end
    
    def self.native_class
      self.to_s.split('::').last.constantize
    end
  end
  
  # Store these objects serialized by default
  class Array < Object; end;
  class Hash < Object; end;
  class OpenStruct < Object; end;
end
  


module DataType
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
      @value || ((self.column[:type] == :text)? %W{Several lines of long text.}.join("\n") : "Some string")
    end
  end
end
  


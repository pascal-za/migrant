module DataType
  class String < Base
    def column
      if @value.match(/[\d,]+\.\d{2}$/)
        return Currency.new(@options).column
      else
        return @value.match(/[\r\n\t]/)? { :type => :text }.merge(@options) : super
      end
    end
  end
end
  


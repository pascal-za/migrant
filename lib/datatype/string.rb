module DataType
  class String < Base
    def migration
      if @value.match(/[\d,]+\.\d{2}$/)
        return Currency.new(@options).migration
      else
        return @value.match(/[\r\n\t]/)? { :type => :text } : super
      end
    end
  end
end
  


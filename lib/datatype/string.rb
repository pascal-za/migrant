module DataType
  class String < Base
    def migration
      @value.match(/[\r\n\t]/)? { :type => :text } : super
    end
  end
end
  


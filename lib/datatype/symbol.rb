module DataType
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
  


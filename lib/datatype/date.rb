module DataType
  class Date < Base
    def migration
      {:type => :datetime}
    end
  end
end
  


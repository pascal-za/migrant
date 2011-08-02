class Customer < User
  structure do
    money_spent   "$5.00"
    money_gifted  "NOK 550.00" 
    average_rating 5.00, :default => 0.0
  end
end

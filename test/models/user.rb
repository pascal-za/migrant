class User < ActiveRecord::Base
  structure do
    name               DataType::Name
    email              DataType::Email
    encrypted_password :size => 48
    password_salt      :size => 42
  end
end

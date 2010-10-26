class User < ActiveRecord::Base
  structure do
    name               DataType::Sentence
    email              DataType::Email
    encrypted_password :limit => 48
    password_salt      :limit => 42
  end
end

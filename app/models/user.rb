class User < ApplicationRecord
   validates :username, presence: true, uniqueness: true
   validates :password_digest, presence: true
   validates :password, length: { minimum: 5, allow_nil: true } 

   attr_reader :password
end

class User < ApplicationRecord
   validates :username, presence: true, uniqueness: true
   validates :password_digest, presence: true
   validates :password, length: { minimum: 5, allow_nil: true } 
   after_initialize :ensure_session_token

   attr_reader :password

   def self.generate_session_token
      SecureRandom::urlsafe_base64(16)
   end
   def password=(password)
      @password = password
      self.password_digest = BCrypt::Password.create(password)
   end

   private
   def ensure_session_token
      self.session_token ||= self.class.generate_session_token
   end
end

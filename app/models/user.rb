class User < ApplicationRecord
   validates :username, presence: true, uniqueness: true
   validates :password_digest, presence: true
   validates :password, length: { minimum: 5, allow_nil: true } 
   after_initialize :ensure_session_token

   attr_reader :password

   def self.generate_session_token
      SecureRandom::urlsafe_base64(16)
   end

   def self.find_by_credentials(username, password)
      user = self.find_by(username: username)
      return user if user && user.is_password?(password)
      nil
   end

   def is_password?(password)
      BCrypt::Password.new(self.password_digest) == password
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

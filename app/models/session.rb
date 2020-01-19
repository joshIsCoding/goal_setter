class Session < ApplicationRecord
   validates :session_token, presence: true, uniqueness: true
   belongs_to :user
   after_initialize :ensure_session_token

   def self.generate_session_token
      SecureRandom::urlsafe_base64(16)
   end

   private
   def ensure_session_token
      self.session_token ||= self.class.generate_session_token
   end
end

class Session < ApplicationRecord
  validates :session_token, presence: true, uniqueness: true
  belongs_to :user

  def self.generate_session_token
      SecureRandom::urlsafe_base64(16)
   end
end

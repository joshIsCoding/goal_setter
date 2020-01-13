class User < ApplicationRecord
   include Commentable
   validates :username, presence: true, uniqueness: true
   validates :password_digest, presence: true
   validates :password, length: { minimum: 5, allow_nil: true } 
   validates_numericality_of( 
      :up_votes_left, 
      only_integer: true, 
      greater_than_or_equal_to: 0,
      on: :create
   )

   after_initialize :ensure_session_token
   before_validation :ensure_up_votes_left

   attr_reader :password

   has_many :goals, dependent: :destroy
   has_many :up_votes, dependent: :destroy
   
   has_many :up_voted_goals, through: :up_votes, source: :goal
   has_many :received_up_votes, through: :goals, source: :up_votes
   has_many( :authored_comments, 
      class_name: "Comment",
      foreign_key: :author_id,
      primary_key: :id,
      dependent: :destroy
  )

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

   def reset_session_token!
      self.session_token = self.class.generate_session_token
      self.save!
      self.session_token
   end

   def increment_up_votes_left!
      self.up_votes_left += 1
      self.save!
      self.up_votes_left
   end

   def decrement_up_votes_left!
      self.up_votes_left -= 1
      self.save!
      self.up_votes_left
   end

   private
   def ensure_session_token
      self.session_token ||= self.class.generate_session_token
   end

   def ensure_up_votes_left
      self.up_votes_left ||= UpVote::UP_VOTE_LIMIT
   end
end

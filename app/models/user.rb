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

   has_many :goals, -> { order "created_at DESC"}, dependent: :destroy
   has_many :completed_goals, -> { where status: "Complete" }, class_name: "Goal"
   
   has_many :sessions, -> { order "created_at DESC"}, dependent: :destroy   
   
   has_many :up_votes, dependent: :destroy   
   has_many :up_voted_goals, through: :up_votes, source: :goal
   has_many :received_up_votes, through: :goals, source: :up_votes
   has_many( :authored_comments, 
      class_name: "Comment",
      foreign_key: :author_id,
      primary_key: :id,
      dependent: :destroy
  )
  has_many :notifications, -> { order "created_at DESC" }, dependent: :destroy
  has_many(
     :triggered_events, 
     class_name: "KeyEvent", 
     foreign_key: :instigator_id, 
     dependent: :destroy
   )

   scope :with_goals_count, -> do
      select("users.*, COUNT(DISTINCT goals.id) AS \"goals_count\"")
      .left_outer_joins(:goals)
      .group(:id)
   end
   scope :with_upvotes_count, -> do
      select("users.*, COUNT(DISTINCT up_votes.id) AS \"upvotes_count\"")
      .left_outer_joins(:received_up_votes)
      .group(:id)
   end
   scope :sorted_alphabetically, -> { order(:username) }

   def self.generate_session_token
      SecureRandom::urlsafe_base64(16)
   end

   def self.find_by_credentials(username, password)
      user = self.find_by(username: username)
      return user if user && user.is_password?(password)
      nil
   end

   def self.leaderboard
      self.find_by_sql(<<-SQL) 
      SELECT   
         users.*, COUNT(goals.id) AS goal_count, SUM ( 
            CASE WHEN goals.status = 'Complete'
            THEN 1
            ELSE 0
            END
         ) AS completed_goal_count, COALESCE( 100 * SUM (
            CASE WHEN goals.status = 'Complete'
            THEN 1
            ELSE 0
            END
         ) / NULLIF(COUNT(goals.id), 0), 0) AS goal_completion_rate
      FROM
         users
      LEFT OUTER JOIN
         goals ON goals.user_id = users.id
      GROUP BY
         users.id
      ORDER BY
         completed_goal_count DESC
      LIMIT 
         10
      SQL
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

   def has_up_votes_remaining?
      self.up_votes_left > 0
   end

   private
   def ensure_session_token
      self.session_token ||= self.class.generate_session_token
   end

   def ensure_up_votes_left
      self.up_votes_left ||= UpVote::UP_VOTE_LIMIT
   end
end

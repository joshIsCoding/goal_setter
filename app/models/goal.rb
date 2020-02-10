class Goal < ApplicationRecord
   include Commentable
   STATUSES = [
      "Not Started",
      "In Progress",
      "Complete"
   ].freeze
   
   validates :title, uniqueness: { scope: :user_id },  presence: true
   validates :status, inclusion: { in: STATUSES }

   belongs_to :user
   has_many :up_votes, dependent: :destroy
   has_and_belongs_to_many :categories

   def self.leaderboard
      self.select("goals.*, COUNT(up_votes.id) AS \"up_votes_count\"")
      .left_outer_joins(:up_votes)
      .group(:id)
      .order(up_votes_count: :desc)
      .limit(10)
   end

   def get_up_vote(user)
      UpVote.find_by(user: user, goal: self)      
   end

end

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

   def get_up_vote(user)
      UpVote.find_by(user: user, goal: self)      
   end

end

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

   def has_up_vote?(user)
      prior_up_vote = self.up_votes.where("up_votes.user_id = ?", user.id)
      prior_up_vote.exists?
   end

end

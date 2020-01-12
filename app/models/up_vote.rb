class UpVote < ApplicationRecord
  UP_VOTE_LIMIT = 10
  belongs_to :user
  belongs_to :goal
  validates :goal_id, uniqueness: { scope: :user_id }
  validate :user_has_up_votes_left
  

  private
  def user_has_up_votes_left
    return unless self.user
    unless UP_VOTE_LIMIT > self.user.up_votes.count
      errors.add(:user, "has no upvotes remaining")
    end
  end
end

class UpVote < ApplicationRecord
  include Eventable

  UP_VOTE_LIMIT = 3
  belongs_to :user
  belongs_to :goal
  validates :goal_id, uniqueness: { scope: :user_id }
  validate :user_has_up_votes_left
  after_create :decrement_user_up_votes!
  after_create { generate_event("new") }
  after_destroy :increment_user_up_votes!
  
  private

  def decrement_user_up_votes!
    self.user.decrement_up_votes_left!
  end

  def increment_user_up_votes!
    self.user.increment_up_votes_left!
  end

  def user_has_up_votes_left
    return unless self.user
    unless self.user.up_votes_left > 0
      errors.add(:user, "has no upvotes remaining")
    end
  end
end

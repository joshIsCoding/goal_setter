class Notification < ApplicationRecord
  validates :key_event_id, uniqueness: { scope: :user_id }
  belongs_to :user, inverse_of: :notifications
  belongs_to :key_event, inverse_of: :notifications
  has_one :instigator, through: :key_event, source: :instigator
  has_one :upvote, through: :key_event, source: :eventable, source_type: "UpVote"
  has_one :goal, through: :key_event, source: :eventable, source_type: "Goal"
  has_one :comment, through: :key_event, source: :eventable, source_type: "Comment"

  scope :unseen, -> { where(seen: false) }
  scope :menu, -> { limit(10) }
end

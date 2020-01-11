class UpVote < ApplicationRecord
  validates :goal_id, uniqueness: { scope: :user_id }
  belongs_to :user
  belongs_to :goal
end

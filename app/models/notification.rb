class Notification < ApplicationRecord
  validates :key_event_id, uniqueness: { scope: :user_id }
  belongs_to :user, inverse_of: :notifications
  belongs_to :key_event, inverse_of: :notifications
end

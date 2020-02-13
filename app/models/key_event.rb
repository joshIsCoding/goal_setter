class KeyEvent < ApplicationRecord
  validates_inclusion_of :event_type, in: ["new", "update"]
  belongs_to :eventable, polymorphic: true
  belongs_to :instigator, class_name: "User"
  has_many :notifications, dependent: :destroy
  after_create :generate_notifications

  private

  def notification_recipients
    recipients = []
    case self.eventable_type
    when "UpVote"
      recipients << self.eventable.goal.user
    when "Goal"
      upvotes = self.eventable.up_votes.includes(:user)
      recipients = upvotes.map(&:user)
    end
    return recipients
  end

  def generate_notifications
    Notification.transaction do
      notification_recipients.each do |recipient| 
        Notification.create(user: recipient, key_event: self)
      end
    end
    self.notifications_generated = true    
  end
end

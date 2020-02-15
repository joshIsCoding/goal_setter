module NotificationsHelper
  NOTIFICATION_MESSAGES = {
    "new-Comment" => " commented after you.",
    "new-UpVote"  => " just upvoted your goal!",
    "update-Goal" => " has updated their goal."
  }.freeze

  def parse_notification(notification)
    key_event = notification.key_event
    lookup = key_event.event_type + "-" + key_event.eventable_type
    key_event.instigator.username.to_s + NOTIFICATION_MESSAGES[lookup]
  end

  def notification_count
      count = current_user.notifications.unseen.count
      if count > 9
         return "9+"
      elsif count <= 0 
         return nil
      else
         return count
      end
   end
end

module NotificationsHelper
  NOTIFICATION_MESSAGES = {
    "new-Comment" => "commented after you",
    "new-UpVote"  => "just upvoted your goal",
    "update-Goal" => "has updated their goal",
    "new-Comment-verbose" => "also commented on ",
    "new-UpVote-verbose"  => "upvoted your goal ",
    "update-Goal-verbose" => "has updated their goal ",
  }.freeze

  def parse_notification(notification, verbose = false)
    key_event = notification.key_event
    lookup = key_event.event_type + "-" + key_event.eventable_type
    unless verbose
      return NOTIFICATION_MESSAGES[lookup]
    else
      lookup += "-verbose"
      message = NOTIFICATION_MESSAGES[lookup]     
      message += "<strong class=\"event-name #{key_event.eventable_type.downcase}\">"
      message += "#{key_event.event_name} </strong>"
      return message.html_safe
    end
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

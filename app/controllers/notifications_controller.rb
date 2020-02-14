class NotificationsController < ApplicationController
  def index
  end

  def update
    @notification = Notification.find_by_id(params[:id])
    @notification.toggle!(:seen) unless @notification.seen
    case @notification.key_event.eventable_type
    when "UpVote"
      redirect_to goal_url(@notification.upvote.goal)
    else
      redirect_back(fallback_location: root_url)
    end
  end
end

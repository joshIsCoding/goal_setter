class NotificationsController < ApplicationController
  before_action :get_notification, except: [:index]
  def index
  end

  def update
    @notification.toggle!(:seen) unless @notification.seen
    case @notification.key_event.eventable_type
    when "UpVote"
      redirect_to goal_url(@notification.upvote.goal)
    when "Goal"
      redirect_to goal_url(@notification.goal)
    when "Comment"
      if @notification.comment.commentable_type == "Goal"
        redirect_to goal_url(
          @notification.comment.commentable, 
          anchor: "comments"
        )
      elsif @notification.comment.commentable_type == "User"
        redirect_to user_url(
          @notification.comment.commentable, 
          anchor: "comments"
        )
      end
    else
      redirect_back(fallback_location: root_url)
    end
  end

  private
  def get_notification
    @notification = Notification.find_by_id(params[:id])
    unless @notification
      redirect_back(fallback_location: root_url)
    end
  end
end

class CommentsController < ApplicationController
   before_action :ensure_log_in
   def create
      @comment = Comment.new(comment_params.permit(:contents, :commentable_type, :commentable_id))
      @comment.author = current_user

      fallback = comment_params[:commentable_type] == "Goal" ? 
      goal_url(comment_params[:commentable_id]) :
      user_url(comment_params[:commentable_id])

      flash[:errors] = @comment.errors.full_messages unless @comment.save         
      redirect_back(fallback_location: fallback)
   end

   private
   def comment_params
      params.require(:comment)
   end

end

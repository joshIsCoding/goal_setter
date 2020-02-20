class CommentsController < ApplicationController

   def create
      @comment = Comment.new(comment_params.permit(
         :contents, 
         :commentable_type, 
         :commentable_id))
      @comment.author = current_user
      if@comment.save   
         redirect_to anchored_redirect_url(@comment)
      else
         flash[:errors] = @comment.errors.full_messages
         redirect_back(fallback_location: root_url) 
      end   
      
   end

   def destroy
      @comment = Comment.find_by_id(params[:id])
      render_not_found unless @comment
      @comment.destroy if @comment.author == current_user
      redirect_back(fallback_location: user_url(@comment.author))
   end         

   private
   def comment_params
      params.require(:comment)
   end

   def anchored_redirect_url(new_comment)
      if new_comment.commentable_type == "Goal"
         return goal_url(new_comment.commentable, anchor: "c-#{new_comment.id}")
      elsif new_comment.commentable_type == "User"
         return user_url(new_comment.commentable, anchor: "c-#{new_comment.id}")
      end
   end

end

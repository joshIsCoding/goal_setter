class CommentsController < ApplicationController
   before_action :ensure_login
   def create
      @comment = Comment.new(comment_params.permit(
         :contents, 
         :commentable_type, 
         :commentable_id))
      @comment.author = current_user

      flash[:errors] = @comment.errors.full_messages unless @comment.save         
      redirect_to anchored_redirect_url(comment_params[:commentable_type], 
         comment_params[:commentable_id])
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

   def anchored_redirect_url(target_class, target_id)
      return goal_url(target_id, anchor: target_id) if target_class == "Goal"
      user_url(target_id, anchor: target_id)
   end

end

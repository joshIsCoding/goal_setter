class UpVotesController < ApplicationController

   def create
      up_vote_params = params[:up_vote]
      target_goal = Goal.find_by_id(up_vote_params[:goal_id])
      unless target_goal.user == current_user 
         up_vote = UpVote.new(goal: target_goal, user: current_user)
         if up_vote.save
            flash[:notices] = ["Goal Upvoted!"]
         else
            flash[:errors] = up_vote.errors.full_messages
         end
      end
      redirect_back(fallback_location: user_url(target_goal.user))
   end

   def destroy
      up_vote = UpVote.find_by_id(params[:id])
      if up_vote.user == current_user
         up_vote.destroy
         flash[:notices] = ["Goal Downvoted"]
      end
      redirect_back(fallback_location: user_url(up_vote.goal.user_id))
   end

   

   private

   def up_vote_params
      params.require(:up_vote).permit(:goal_id)
   end
end
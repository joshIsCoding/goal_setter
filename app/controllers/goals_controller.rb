class GoalsController < ApplicationController
   def new
      @goal = Goal.new
      render :new
   end

   def create
      @goal = Goal.new(goal_params)
      @goal.user = current_user
      if @goal.save
         redirect_to user_url(current_user, anchor: @goal.id)
      else
         flash.now[:errors] = @goal.errors.full_messages
         render :new
      end
   end

   private
   def goal_params
      params.require(:goal).permit(:title, :details, :status, :public)
   end
end

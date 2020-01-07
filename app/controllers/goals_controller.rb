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

   def edit
      @goal = Goal.find_by_id(params[:id])
      if @goal.user == current_user
         render :edit
      else
         redirect_to goal_url(@goal)
      end
   end

   def update
      @goal = Goal.find_by_id(params[:id])
      if @goal.update(goal_params)
         redirect_to user_url(current_user, anchor: @goal.id)
      else
         flash.now[:errors] = @goal.errors.full_messages
         render :edit
      end
   end

   def show
      @goal = Goal.find_by_id(params[:id])
      if @goal
         render :show
      else
         render_not_found
      end
   end


   private
   def goal_params
      params.require(:goal).permit(:title, :details, :status, :public)
   end
end

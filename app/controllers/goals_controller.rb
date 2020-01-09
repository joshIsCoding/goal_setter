class GoalsController < ApplicationController
   before_action :find_and_validate_goal, only: [:edit, :update]
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
      render :edit
   end

   def update
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

   def destroy
      @goal = Goal.find_by_id(params[:id])
      if @goal.destroy
         redirect_to controller: :users, action: :show, id: @goal.user_id
      else
         flash.now[:errors] = @goal.errors.full_messages
         render goal_url(@goal)
      end
   end

   
   private
   def goal_params
      params.require(:goal).permit(:title, :details, :status, :public)
   end

   def find_and_validate_goal
      @goal = Goal.find_by_id(params[:id])
      redirect_to goal_url(@goal) unless @goal.user == current_user
   end
end

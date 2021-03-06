class GoalsController < ApplicationController
   before_action :find_and_validate_goal, only: [:edit, :update, :destroy]
   skip_before_action :ensure_login, only: [:index]
   
   def new
      @goal = Goal.new
      render :new
   end

   def create
      @goal = Goal.new(goal_params)
      @goal.user = current_user
      if @goal.save
         flash[:success] = ["Goal Set!"]
         redirect_to user_url(current_user, anchor: "g-#{@goal.id}")
      else
         flash.now[:errors] = @goal.errors.full_messages
         render :new
      end
   end

   def edit
   end

   def update
      if @goal.update(goal_params)
         flash[:success] = ["Goal Updated!"]
         if request.referrer == edit_goal_url(@goal)
            redirect_to goal_url(@goal)
         else
            redirect_to user_url(current_user, anchor: "g-#{@goal.id}")
         end
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

   def index
      if params.include?(:category)
         @category = params[:category]
         @goals = Category.find_by(name: params[:category])
         .goals
         .with_up_votes_count
         .with_comments_count
         .set_public
      else
         @goals = Goal.all
         .with_up_votes_count
         .with_comments_count
         .set_public
      end
   end

   def destroy
      if @goal.destroy
         flash[:success] = ["Goal Deleted"]
         redirect_to controller: :users, action: :show, id: @goal.user_id
      else
         flash.now[:errors] = @goal.errors.full_messages
         render goal_url(@goal)
      end
   end

   
   private
   def goal_params
      params.require(:goal).permit(
         :title, 
         :details, 
         :status, 
         :public, 
         category_ids: []
      )
   end

   def find_and_validate_goal
      @goal = Goal.find_by_id(params[:id])
      render_not_found unless @goal
      redirect_to goal_url(@goal) unless @goal.user == current_user
   end
end

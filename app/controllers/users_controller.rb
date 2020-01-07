class UsersController < ApplicationController
   before_action :ensure_login, only: [:show]
   before_action :already_logged_in, except: [:show]
   
   def new
      @user = User.new
      render :new
   end

   def create
      @user = User.new(user_params)
      if @user.save
         login_user!(@user)
         redirect_to user_url(@user)
      else
         flash.now[:errors] = @user.errors.full_messages
         render :new
      end
   end

   def show
      @user = User.find_by_id(params[:id])
      if @user
         @sorted_goals = @user.goals ? @user.goals.order(:created_at) : []
         render :show
      else
         redirect_to :index
      end
   end

   def index
      @users = User.select("users.*, COUNT(goals.id) AS \"goal_count\"").joins(:goals).group(:id)
      render :index
   end

   private
   def user_params
      params.require(:user).permit(:username, :password)
   end
end

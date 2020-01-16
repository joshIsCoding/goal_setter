class UsersController < ApplicationController
   before_action :ensure_login, only: [:show]
   before_action :already_logged_in, only: [:create, :new]
   
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
         render :show
      else
         redirect_to users_url
      end
   end

   def index
      @users = User.select("users.*, COUNT(goals.id) AS \"goal_count\"").left_outer_joins(:goals).group(:id)
      render :index
   end

   private
   def user_params
      params.require(:user).permit(:username, :password)
   end
end

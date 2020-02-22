class UsersController < ApplicationController
   skip_before_action :ensure_login, except: [:show]
   before_action :already_logged_in, only: [:create, :new]
   
   def new
      @user = User.new
   end

   def create
      @user = User.new(user_params)
      if @user.save
         login_user!(@user)
         redirect_to root_url
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
      @users = User.all
      .with_goals_count
      .with_upvotes_count
      .sorted_alphabetically
   end

   private
   def user_params
      params.require(:user).permit(:username, :password)
   end
end

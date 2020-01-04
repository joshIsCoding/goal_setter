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
      @sorted_goals = @user.goals.order(:created_at)
      if @user
         render :show
      else
         render plain: "You cannot access this content", status: 404
      end
   end

   private
   def user_params
      params.require(:user).permit(:username, :password)
   end
end

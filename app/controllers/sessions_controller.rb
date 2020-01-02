class SessionsController < ApplicationController

   def new
      render :new
   end

   def create
      @user = User.find_by_credentials(user_params[:username], user_params[:password])
      if @user
         login_user!(@user)
         redirect_to user_url(@user)
      else
         flash.now[:errors] ||= []
         flash.now[:errors] << "Sorry, those credentials weren't valid."
         render :new
      end
   end
   
   private
   def user_params
      params[:user]
   end
end

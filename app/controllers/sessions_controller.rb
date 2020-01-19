class SessionsController < ApplicationController
   skip_before_action :ensure_login, except: [:destroy]
   before_action :already_logged_in, except: [:index, :destroy]
   def new
   end

   def index
   end

   def create
      @user = User.find_by_credentials(user_params[:username], user_params[:password])
      if @user
         login_user!(@user)
         redirect_to root_url
      else
         flash.now[:errors] ||= []
         flash.now[:errors] << "Sorry, those credentials weren't valid."
         render :new
      end
   end

   def destroy
      session = Session.find_by_id(params[:id])
      logout!(session) if session
      if is_logged_in?
         redirect_back(fallback_location: user_url(current_user))
      else         
         redirect_to root_url
      end
   end
   
   private
   def user_params
      params[:user]
   end
end

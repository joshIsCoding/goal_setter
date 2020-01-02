class ApplicationController < ActionController::Base
   helper_method :current_user, :is_logged_in?
   
   def current_user
      @current_user ||= User.find_by(session_token: session[:session_token])
   end

   def is_logged_in?
      !current_user.nil?
   end

   def login_user!(user)
      @current_user = user
      session[:session_token] = user.reset_session_token! 
   end

   def ensure_login
      if !is_logged_in?
         flash[:errors] ||= []
         flash[:errors] << "Please login to view this page"
         redirect_to new_session_url
      end
   end

   def already_logged_in
      if is_logged_in?
         redirect_to user_url(current_user)
      end
   end
end

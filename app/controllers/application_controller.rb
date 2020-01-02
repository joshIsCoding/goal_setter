class ApplicationController < ActionController::Base
   helper_method :current_user, :is_logged_in?
   
   def current_user
      User.find_by(session_token: session[:session_token])
   end

   def is_logged_in?
      !current_user.nil?
   end

   def login_user!(user)
      session[:session_token] = user.reset_session_token! unless user == current_user
   end
end

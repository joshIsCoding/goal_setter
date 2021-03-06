class ApplicationController < ActionController::Base
   before_action :ensure_login
   
   helper_method :current_user, :current_session, :is_logged_in?
   
   def current_user
      @current_user ||= (current_session ? current_session.user : nil)
   end

   def current_session
      @current_session ||= Session.find_by(session_token: session[:session_token])
   end

   def is_logged_in?
      !current_session.nil?
   end

   def login_user!(user)
      @current_user = user
      @current_session = Session.create!(
         user: user,
         user_agent: request.env["HTTP_USER_AGENT"],
         remote_ip: request.remote_ip,
         city: request.location.city
      )
      session[:session_token] = @current_session.session_token
   end

   def logout!(session)
      if session == current_session
         session[:session_token], @current_session = nil, nil
      end
      session.destroy!
   end

   def ensure_login
      unless is_logged_in?
         flash[:errors] ||= []
         flash[:errors] << "Please login to view this page"
         redirect_to login_url
      end
   end

   def already_logged_in
      if is_logged_in?
         redirect_to root_url
      end
   end

   def render_not_found
      raise ActionController::RoutingError.new('Page not found')
   end
end

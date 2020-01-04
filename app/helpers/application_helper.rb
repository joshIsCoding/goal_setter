module ApplicationHelper
   def auth_token
      auth_string = <<-HTML
         <input type="hidden" 
         name="authenticity_token" 
         value= #{form_authenticity_token}" >
      HTML
      auth_string.html_safe
   end
end

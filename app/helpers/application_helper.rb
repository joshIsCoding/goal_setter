module ApplicationHelper
   def auth_token
      auth_string = "<input type=\"hidden\" "
      auth_string << "name=\"authenticity_token\" "
      auth_string << "value=\"#{form_authenticity_token}\" >"
      auth_string.html_safe
   end
end

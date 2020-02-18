module ApplicationHelper
   UP_VOTE_ICONS = {
      "up" => "<i aria=hidden=\"true\" class=\"fas fa-chevron-circle-up\" title=\"Up Vote\"></i>",
      "down" => "<i aria=hidden=\"true\" class=\"fas fa-chevron-circle-down\" title=\"Remove Up Vote\"></i>"
   }
   
   def auth_token
      auth_string = "<input type=\"hidden\" "
      auth_string << "name=\"authenticity_token\" "
      auth_string << "value=\"#{form_authenticity_token}\" >"
      auth_string.html_safe
   end
end

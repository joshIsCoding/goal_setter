module ApplicationHelper
   UP_VOTE_ICONS = {
      "up" => "<i aria-hidden=\"true\" class=\"fas fa-chevron-circle-up\" title=\"Up Vote\"></i>",
      "down" => "<i aria-hidden=\"true\" class=\"fas fa-chevron-circle-down\" title=\"Remove Up Vote\"></i>"
   }

   ACTION_ICONS = {
      "edit" => "<i aria-hidden=\"true\" class=\"fas fa-pen-square\" title=\"Edit\"></i><span class=\"sr-only\">Edit goal</span>",
      "delete" => "<i aria-hidden=\"true\" class=\"fas fa-minus-square\" title=\"Delete\"></i><span class=\"sr-only\">Delete goal</span>",
      "complete" => "<i aria-hidden=\"true\" class=\"fas fa-check-square\" title=\"Mark as complete\"></i><span class=\"sr-only\">Mark goal as complete</span>",
      "trash" => "<i aria-hidden=\"true\" class=\"fas fa-trash-alt\" title=\"Delete comment\"></i><span class=\"sr-only\">Delete comment</span>"
   }
   
   def auth_token
      auth_string = "<input type=\"hidden\" "
      auth_string << "name=\"authenticity_token\" "
      auth_string << "value=\"#{form_authenticity_token}\" >"
      auth_string.html_safe
   end
end

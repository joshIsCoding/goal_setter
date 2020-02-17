module GoalsHelper
  STATUS_ICONS = {
    "not-started" => "<i aria-hidden=\"true\" class=\"fas fa-thumbtack\" title=\"Goal not started.\"></i>",
    "in-progress" => "<i aria-hidden=\"true\" class=\"fas fa-clipboard-list\" title=\"Goal in progress.\"></i>",
    "complete" => "<i aria-hidden=\"true\" class=\"fas fa-clipboard-check\" title=\"Goal complete.\"></i>"
  }.freeze

  CATEGORY_ICONS = {
    "work" => "<i aria-hidden=\"true\" class=\"fas fa-briefcase\" title=\"work\"></i>",
    "family" => "<i aria-hidden=\"true\" class=\"fas fa-home\" title=\"family\"></i>",
    "relationships" => "<i aria-hidden=\"true\" class=\"far fa-heart\" title=\"relationships\"></i>",
    "study" => "<i aria-hidden=\"true\" class=\"fas fa-book\" title=\"study\"></i>",
    "health" => "<i aria-hidden=\"true\" class=\"fas fa-weight\" title=\"health\"></i>",
    "hobbies" => "<i aria-hidden=\"true\" class=\"fas fa-camera\" title=\"hobbies\"></i>",
    "travel" => "<i aria-hidden=\"true\" class=\"fas fa-globe-americas\" title=\"travel\"></i>"
  }
end

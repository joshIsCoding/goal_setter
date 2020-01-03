class Goal < ApplicationRecord
   STATUSES = [
      "Not Started",
      "In Progress",
      "Complete",
   ]
   validates :title, uniqueness: { scope: :user_id },  presence: true
   validates :status, inclusion: { in: STATUSES }
end

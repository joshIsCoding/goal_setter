class Goal < ApplicationRecord
   STATUSES = [
      "Not Started",
      "In Progress",
      "Complete"
   ].freeze
   
   validates :title, uniqueness: { scope: :user_id },  presence: true
   validates :status, inclusion: { in: STATUSES }

   has_many :comments, as: :commentable
   belongs_to :user
end

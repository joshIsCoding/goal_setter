class Goal < ApplicationRecord
   include Commentable
   STATUSES = [
      "Not Started",
      "In Progress",
      "Complete"
   ].freeze
   
   validates :title, uniqueness: { scope: :user_id },  presence: true
   validates :status, inclusion: { in: STATUSES }

   belongs_to :user
   has_many :up_votes, dependent: :destroy
end

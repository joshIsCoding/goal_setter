class Comment < ApplicationRecord
  validates :contents, presence: true, length: { maximum: 1000 }
  belongs_to :commentable, polymorphic: true
  belongs_to( :author,
    class_name: "User",
    foreign_key: :author_id,
    primary_key: :id
  )
end

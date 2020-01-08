class Comment < ApplicationRecord
  validates :contents, presence: true, length: { maximum: 1000 }
  belongs_to :commentable, polymorphic: true
end

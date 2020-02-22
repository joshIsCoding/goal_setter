class Comment < ApplicationRecord
  include Eventable

  validates :contents, presence: true, length: { maximum: 1000 }
  after_create { generate_event("new") }
  belongs_to :commentable, polymorphic: true
  belongs_to( :author,
    class_name: "User",
    foreign_key: :author_id,
    primary_key: :id
  )

  default_scope { order("created_at ASC")}

  def prior_comments
    self.commentable.comments.where("created_at < ? ", self.created_at)
  end

  def asset_owner #overwrites Eventable method
    self.author    
  end
end

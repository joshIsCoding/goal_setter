require 'active_support/concern'

module Commentable
   extend ActiveSupport::Concern

   included do
      has_many :comments, as: :commentable
   end

   def authored_comments
      self.comments.select(<<-SQL)
         comments.*, 
         users.username AS "author_name", 
         users.id AS "author_id"
      SQL
      .joins(:author)
   end
end
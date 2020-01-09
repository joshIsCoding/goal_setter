require 'active_support/concern'

module Commentable
   extend ActiveSupport::Concern

   included do
      has_many :comments, as: :commentable
   end

   def sorted_authored_comments
      if self.comments
         return self.comments.select(<<-SQL)
            comments.*, 
            users.username AS "author_name", 
            users.id AS "author_id"
         SQL
         .joins(:author)
         .order(:created_at)
      else 
         return []
      end
   end
end
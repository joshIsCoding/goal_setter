require 'active_support/concern'

module Commentable
   extend ActiveSupport::Concern

   included do
      has_many :comments, as: :commentable
   end

end
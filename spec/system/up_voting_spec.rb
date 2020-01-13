require 'rails_helper'

RSpec.describe "Up and Down Voting Goals", type: :system do
   context "From Another User's Page" do
      
      it "let's a user add an upvote to any of the listed goals"

      it "shows the user how many upvotes they have remaining"

      it "allows the user to downvote a prior upvote to recoup a new potential upvote"

      it "does not allow a user to upvote any single goal more than once"

      it "does not allow a user to upvote more than their allotted number of upvotes"

   end

   context "From a Goal Page" do 
      it "lets a user upvote the goal"

      it "does not let the user upvote the goal more than once"

      it "allows the user to downvote their upvote, recouperating that upvote"

   end

   context "From Their Own User Page" do
      
      it "doesn't allow the user to upvote their own goals"
   end

   context "From Their Own Goal Page" do
      it "doesn't allow the user to upvote their own goals"
   end
end
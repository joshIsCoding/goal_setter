require 'rails_helper'

RSpec.describe "Up and Down Voting Goals", type: :system do
   let(:main_user) { User.create!(username: "main", password:"mainpass") }
   let(:other_user) { User.create!(username: "other", password:"otherpass") }
   let(:token_goal) { Goal.create!(title: "This is my goal", details: "To write more goals.", user: other_user) }

   before(:each) do
      visit(new_session_path)
      fill_in("user_username", with: main_user.username)
      fill_in("user_password", with: main_user.password)
      click_on("Sign In")
   end

   context "From Another User's Page" do
      
      let!(:goals) do
         goals = []
         UpVote::UP_VOTE_LIMIT.times do |i| 
            goals << Goal.create!(title: "Goal ##{i+1}", user: other_user, public: true)
         end
         goals
      end

      let!(:unvotable_goal) { Goal.create!(title: "Un-upvotable Goal", user: other_user, public: true) }
      
      before(:each){ visit(user_path(other_user)) }
      
      it "let's a user add an upvote to any of the listed goals" do
         within("table#goals_table") do
            expect(find("tr#g-#{goals.last.id}")).to have_button("uv-#{goals.last.id}")
            # total upvotes for the target goal should be zero
            expect(find("tr#g-#{goals.last.id}")).to have_text("0")
            find("tr#g-#{goals.last.id}").click_on("uv-#{goals.last.id}")
            expect(find("tr#g-#{goals.last.id}")).to have_text("1")
            # total upvotes for the target goal should now be one
         end
      end

      it "shows the user how many upvotes they have remaining" do
         expect(find("header#user_controls")).to have_text("#{UpVote::UP_VOTE_LIMIT} upvotes remaining")
      end

      it "allows the user to downvote a prior upvote to recoup a new potential upvote" do
         expect(find("header#user_controls")).to have_text("#{UpVote::UP_VOTE_LIMIT} upvotes remaining")
         
         within("table#goals_table") do
            # click up vote
            find("tr#g-#{goals.first.id}").click_on("uv-#{goals.first.id}")
            expect(find("tr#g-#{goals.first.id}")).to have_text("1")
         end

         expect(find("header#user_controls")).to have_text("#{UpVote::UP_VOTE_LIMIT-1} upvotes remaining")
         
         within("table#goals_table") do
            # click down vote
            find("tr#g-#{goals.first.id}").click_on("dv-#{goals.first.id}")
            expect(find("tr#g-#{goals.first.id}")).to have_text("0")
         end
         
         expect(find("header#user_controls")).to have_text("#{UpVote::UP_VOTE_LIMIT} upvotes remaining")
      end

      it "does not allow a user to upvote any single goal more than once" do
         within("table#goals_table") do
            goals.each do |goal|
               find("tr#g-#{goal.id}").click_on("uv-#{goal.id}")
               # no upvote button after goal upvoted
               expect(find("tr#g-#{goal.id}")).not_to have_button("uv-#{goal.id}")
            end
         end
      end

      it "does not allow a user to upvote more than their allotted number of upvotes" do
         within("table#goals_table") do
            expect(find("tr#g-#{unvotable_goal.id}")).to have_button("uv-#{unvotable_goal.id}")
            goals.each do |goal|
               find("tr#g-#{goal.id}").click_on("uv-#{goal.id}")
            end
            # upvote button for last goal should dissappear after user's upvotes used up
            expect(find("tr#g-#{unvotable_goal.id}")).not_to have_button("uv-#{unvotable_goal.id}")
         end
      end

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
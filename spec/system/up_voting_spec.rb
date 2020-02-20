require 'rails_helper'

RSpec.describe "Up and Down Voting Goals", type: :system do
   let(:main_user) { User.create!(username: "main", password:"mainpass") }
   let(:other_user) { User.create!(username: "other", password:"otherpass") }
   let(:token_goal) do
       Goal.create!(title: "This is my goal", 
         details: "To write more goals.", 
         user: other_user
      ) 
   end

   before(:each) do
      visit(login_path)
      fill_in("user_username", with: main_user.username)
      fill_in("user_password", with: main_user.password)
      click_on("Sign In")
   end

   context "From Another User's Page" do
      
      let!(:goals) do
         goals = []
         UpVote::UP_VOTE_LIMIT.times do |i| 
            goals << Goal.create!(title: "Goal ##{i+1}", 
               user: other_user, 
               public: true
            )
         end
         goals
      end

      let!(:bonus_goal) do 
         Goal.create!(title: "Un-upvotable Goal", user: other_user, public: true) 
      end
      
      before(:each) do 
         visit(user_path(other_user)) 
      end
      
      it "let's a user add an upvote to any of the listed goals" do
         within("section.user-show-goals") do
            expect(find("aside.up-vote-widget", match: :first)).to have_button("uv-#{bonus_goal.id}")
            # total upvotes for the target goal should be zero
            expect(find("aside.up-vote-widget", match: :first)).to have_text("0")
            find("aside.up-vote-widget", match: :first).click_on("uv-#{bonus_goal.id}")
            expect(find("aside.up-vote-widget", match: :first)).to have_text("1")
            # total upvotes for the target goal should now be one
         end
      end

      it "shows the user how many upvotes they have remaining" do
         expect(find("strong.upvotes-left")).to have_text("#{UpVote::UP_VOTE_LIMIT}")
      end

      it "allows the user to downvote a prior upvote to recoup a new potential upvote" do
         expect(find("strong.upvotes-left")).to have_text("#{UpVote::UP_VOTE_LIMIT}")
         
         within("section.user-show-goals") do
            # click up vote
            find("aside.up-vote-widget", match: :first).click_on("uv-#{bonus_goal.id}")
            expect(find("aside.up-vote-widget", match: :first)).to have_text("1")
         end

         expect(find("strong.upvotes-left")).to have_text("#{UpVote::UP_VOTE_LIMIT-1}")
         
         within("section.user-show-goals") do
            # click down vote
            find("aside.up-vote-widget", match: :first).click_on("dv-#{bonus_goal.id}")
            expect(find("aside.up-vote-widget", match: :first)).to have_text("0")
         end
         
         expect(find("strong.upvotes-left")).to have_text("#{UpVote::UP_VOTE_LIMIT}")
      end

      it "does not allow a user to upvote any single goal more than once" do
         within("section.user-show-goals") do
            find("aside.up-vote-widget", match: :first).click_on("uv-#{bonus_goal.id}")
            # no upvote button after goal upvoted
            expect(find("aside.up-vote-widget", match: :first)).not_to have_button("uv-#{bonus_goal.id}")
         end
      end

      it "does not allow a user to upvote more than their allotted number of upvotes" do
         within("section.user-show-goals") do
            expect(find("aside.up-vote-widget", match: :first)).to have_button("uv-#{bonus_goal.id}")
            goals.each do |goal|
               click_on("uv-#{goal.id}")
            end
            # upvote button for last goal should dissappear after user's upvotes used up
            expect(find("aside.up-vote-widget", match: :first)).not_to have_button("uv-#{bonus_goal.id}")
         end
      end

   end

   context "From a Goal Page" do 
      before(:each) do 
         visit(goal_path(token_goal)) 
      end
      it "lets a user upvote the goal" do
         expect(page).to have_button("uv-#{token_goal.id}")
         click_on("uv-#{token_goal.id}")
         expect(find("strong.upvotes-left")).to have_text("#{UpVote::UP_VOTE_LIMIT - 1}")
      end

      it "does not let the user upvote the goal more than once" do
         click_on("uv-#{token_goal.id}")
         expect(page).not_to have_button("uv-#{token_goal.id}")
      end

      it "allows the user to downvote their upvote, recouperating that upvote" do
         #click upvote
         click_on("uv-#{token_goal.id}")
         expect(find("strong.upvotes-left")).to have_text("#{UpVote::UP_VOTE_LIMIT - 1}")
         #click downvote
         click_on("dv-#{token_goal.id}")
         expect(find("strong.upvotes-left")).to have_text("#{UpVote::UP_VOTE_LIMIT}")
         
      end

   end

   context "For the User's Own Goals" do
      let!(:main_user_goal) do
         Goal.create!(title: "Main user's goal", 
            details: "Main user can't up or downvote this.", 
            user: main_user
         ) 
      end
      context "From Their Own User Page" do         
         it "doesn't allow the user to up or downvote their own goals" do
            visit(user_path(main_user))
            expect(page).not_to have_button("uv-#{main_user_goal.id}")
            expect(page).not_to have_button("dv-#{main_user_goal.id}")
         end
      end
      context "From Their Own Goal Page" do
         it "doesn't allow the user to up or downvote their own goals" do
            visit(goal_path(main_user_goal))
            expect(page).not_to have_button("uv-#{main_user_goal.id}")
            expect(page).not_to have_button("dv-#{main_user_goal.id}")
         end
      end
   end
end
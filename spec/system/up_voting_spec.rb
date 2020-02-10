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
      visit(new_session_path)
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
         expect(find("header.site-header-bar")).to have_text("#{UpVote::UP_VOTE_LIMIT} upvotes remaining")
      end

      it "allows the user to downvote a prior upvote to recoup a new potential upvote" do
         expect(find("header.site-header-bar")).to have_text("#{UpVote::UP_VOTE_LIMIT} upvotes remaining")
         
         within("table#goals_table") do
            # click up vote
            find("tr#g-#{goals.first.id}").click_on("uv-#{goals.first.id}")
            expect(find("tr#g-#{goals.first.id}")).to have_text("1")
         end

         expect(find("header.site-header-bar")).to have_text("#{UpVote::UP_VOTE_LIMIT-1} upvotes remaining")
         
         within("table#goals_table") do
            # click down vote
            find("tr#g-#{goals.first.id}").click_on("dv-#{goals.first.id}")
            expect(find("tr#g-#{goals.first.id}")).to have_text("0")
         end
         
         expect(find("header.site-header-bar")).to have_text("#{UpVote::UP_VOTE_LIMIT} upvotes remaining")
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
            expect(find("tr#g-#{bonus_goal.id}")).to have_button("uv-#{bonus_goal.id}")
            goals.each do |goal|
               find("tr#g-#{goal.id}").click_on("uv-#{goal.id}")
            end
            # upvote button for last goal should dissappear after user's upvotes used up
            expect(find("tr#g-#{bonus_goal.id}")).not_to have_button("uv-#{bonus_goal.id}")
         end
      end

   end

   context "From a Goal Page" do 
      before(:each) do 
         visit(goal_path(token_goal)) 
      end
      it "lets a user upvote the goal" do
         expect(page).to have_button("uv-#{token_goal.id}")
         within("table") { click_on("uv-#{token_goal.id}") }
         expect(find("header.site-header-bar")).to have_text("#{UpVote::UP_VOTE_LIMIT - 1} upvotes remaining")
      end

      it "does not let the user upvote the goal more than once" do
         within("table") { click_on("uv-#{token_goal.id}") }
         expect(page).not_to have_button("uv-#{token_goal.id}")
      end

      it "allows the user to downvote their upvote, recouperating that upvote" do
         #click upvote
         within("table") { click_on("uv-#{token_goal.id}") }
         expect(find("header.site-header-bar")).to have_text("#{UpVote::UP_VOTE_LIMIT - 1} upvotes remaining")
         #click downvote
         within("table") { click_on("dv-#{token_goal.id}") }
         expect(find("header.site-header-bar")).to have_text("#{UpVote::UP_VOTE_LIMIT} upvotes remaining")
         
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
            save_and_open_page
            expect(page).not_to have_button("uv-#{main_user_goal.id}")
            expect(page).not_to have_button("dv-#{main_user_goal.id}")
         end
      end
      context "From Their Own Goal Page" do
         it "doesn't allow the user to up or downvote their own goals" do
            visit(goal_path(main_user_goal))
            save_and_open_page
            expect(page).not_to have_button("uv-#{main_user_goal.id}")
            expect(page).not_to have_button("dv-#{main_user_goal.id}")
         end
      end
   end
end
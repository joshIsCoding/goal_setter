require 'rails_helper'

RSpec.describe "Goal Creation, Updates and Deletion", type: :system do
   let(:main_user) { User.create!(username: "Main", password: "main_pass")}
   let(:other_user) { User.create!(username: "Other", password: "other_pass")}
   before(:each) do
      visit(new_session_path)
      fill_in("user_username", with: main_user.username)
      fill_in("user_password", with: main_user.password)
      click_on("Sign In")
   end

   describe "Goal Creation" do
      let(:goal_1) { Goal.create!(title: "Big Goal", details: "Smashing life", user: main_user, public?: false)}
      let(:goal_2) { Goal.create!(title: "Mini Goal", details: "Smashing pumpkins", user: main_user)}

      it "lets a user create a new goal for themselves" do
         visit(new_user_goal_path(main_user))
         expect(page).to have_content("Set a new goal!")

      end

      it "Saves the goal and displays it on the user's profile" do
         visit(new_user_goal_path(main_user))
         fill_in("goal[title]", with: "Write more specs!")
         fill_in("goal[details]", with: "Use model and integration tests when creating your web apps.")
         click_on("Set!")
         expect(page).to have_content(main_user.username)
         expect(page).to have_content("Write more specs!")
      end

      it "doesn't let users create goals for other users" do
         visit(new_user_goal_path(other_user))
         expect(page).not_to have_content("Set!")
      end

      it "lets a user see all their goals, public and private" do
         visit(user_path(main_user))
         expect(page).to have_content(goal_1.title)
         expect(page).to have_content(goal_2.title)         
      end
   end

end
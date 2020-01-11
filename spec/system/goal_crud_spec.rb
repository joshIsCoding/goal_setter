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
      it "lets a user create a new goal for themselves" do
         visit(new_user_goal_path(main_user))
         expect(page).to have_content("Set a new goal!")

      end

      it "Saves the goal and displays it on the user's profile" do
         visit(new_user_goal_path(main_user))
         fill_in("goal[title]", with: "Write more specs!")
         fill_in("goal[details]", with: "Use model and integration tests when creating your web apps.")
         click_on("Set!")
         expect(page).to have_content("Goal Set!")
         expect(page).to have_content(main_user.username)
         expect(page).to have_content("Write more specs!")
      end

      it "doesn't let users create goals for other users" do
            visit(new_user_goal_path(other_user))
            fill_in("goal[title]", with: "Write more specs!")
            fill_in("goal[details]", with: "Use model and integration tests when creating your web apps.")
            click_on("Set!")
            expect(page).to have_current_path(user_path(main_user))
            expect(page).to have_content("Write more specs!")
      end

      context "Goal Privacy" do
         let!(:goal_1) { Goal.create!(title: "Big Goal", details: "Smashing life", user_id: main_user.id, public: false)}
         let!(:goal_2) { Goal.create!(title: "Mini Goal", details: "Smashing pumpkins", user_id: main_user.id, public: true)}

         it "lets a user see all their goals, public and private" do
            visit(user_path(main_user))
            expect(page).to have_content(goal_1.title)
            expect(page).to have_content(goal_2.title)         
         end
      end
   end

   describe "Goal Updates" do
      let!(:main_users_goal) { Goal.create!(title: "New Goal", details: "Smashing life", user_id: main_user.id, public: true)}
      let!(:other_users_goal) { Goal.create!(title: "Other Goal", details: "Smashing pumpkins", user_id: other_user.id, public: true)}

      it "allows the user to update their own goals from their page" do 
         visit(user_path(main_user))
         click_on("Update")
         fill_in("goal[title]", with: "Updated Goal")
         click_on("Save!")
         expect(page).to have_content("Goal Updated!")
         expect(page).to have_content("Updated Goal")
      end

      it "allows the user to update their own goals from the goal page" do 
         visit(goal_path(main_users_goal))
         click_on("Update")
         fill_in("goal[title]", with: "Updated Goal")
         click_on("Save!")
         expect(page).to have_content("Goal Updated!")
         expect(page).to have_content("Updated Goal")
      end


      it "doesn't allow users to edit other users' goals from the users' pages" do
         visit(user_path(other_user))
         expect(page).not_to have_button("Update")
      end


      it "doesn't allow users to edit other users' goals from the goal pages" do
         visit(goal_path(other_users_goal))
         expect(page).not_to have_button("Update Goal")
      end

      it "doesn't allow users to edit other users' goals with the direct, edit-goal url" do
         visit(edit_goal_path(other_users_goal))
         expect(page).not_to have_current_path(edit_goal_path(other_users_goal))
         expect(page).not_to have_button("Update Goal")
      end

   end

   describe "Goal Deletion" do
      let!(:main_users_goal) { Goal.create!(title: "New Goal", details: "Smashing life", user_id: main_user.id, public: true)}
      let!(:other_users_goal) { Goal.create!(title: "Other Goal", details: "Smashing pumpkins", user_id: other_user.id, public: true)}
      
      it "allows a user to delete their own goal from the goal page" do
         visit(goal_path(main_users_goal))
         click_on("Delete Goal")
         expect(page).to have_current_path(user_path(main_user))
         expect(page).to have_content("Goal Deleted")
         expect(page).not_to have_content(main_users_goal.title)
      end

      it "also allows a user to delete goals from their own page" do
         visit(user_path(main_user))
         click_on("Delete")
         expect(page).to have_current_path(user_path(main_user))
         expect(page).to have_content("Goal Deleted")
         expect(page).not_to have_content(main_users_goal.title)
      end

      it "doesn't allow a user to delete another user's goal from the goal page" do
         visit(goal_path(other_users_goal))
         expect(page).not_to have_button("Delete Goal")
      end

      it "doesn't allow a user to delete another user's goal from the user's page" do
         visit(user_path(other_user))
         expect(page).to have_content(other_users_goal.title)
         expect(page).not_to have_button("Delete")
      end
   end

end
require 'rails_helper'

RSpec.describe "Adding, Viewing and Deleting Comments", type: :system do
   let(:main_user) {User.create!(username: "main", password:"mainpass") }
   let(:other_user) {User.create!(username: "other", password:"otherpass") }
   let(:token_goal) { Goal.create!(title: "This is my goal", details: "To write more goals.", user: other_user)}
   let(:user_comment) { Comment.create!(contents:"I really like this user.", author: main_user, commentable: other_user)}
   let(:goal_comment) { Comment.create!(contents:"I really like this goal.", author: main_user, commentable: token_goal)}

   before(:each) do
      visit(new_session_path)
      fill_in("user_username", with: main_user.username)
      fill_in("user_password", with: main_user.password)
      click_on("Sign In")
   end
   describe "Viewing Comments" do
      let(:user_comment) { Comment.create!(contents:"I really like this user.", author: main_user, commentable: other_user)}
      let(:goal_comment) { Comment.create!(contents:"I really like this goal.", author: main_user, commentable: token_goal)}
      
      it "shows user comments on the user page." do
         user_comment.valid?
         visit(user_path(other_user))
         expect(page).to have_content(user_comment.contents)
      end

      it "shows goal comments on the goal page." do
         goal_comment.valid?
         visit(goal_path(token_goal))
         expect(page).to have_content(goal_comment.contents)
      end

   end

   describe "Adding Comments" do
      it "lets a user comment on another user's profile" do
         visit(user_path(other_user))
         fill_in("comment_contents", with: "I just added a comment!")
         click_on("Comment")
         expect(page).to have_current_path(user_path(other_user))
         expect(page).to have_content("I just added a comment!")
      end

      it "lets a user comment on another user's goal" do 
         visit(goal_path(token_goal))
         fill_in("comment_contents", with: "I just added a comment!")
         click_on("Comment")
         expect(page).to have_current_path(goal_path(token_goal))
         expect(page).to have_content("I just added a comment!")
      end

   end

   describe "Deleting Comments" do
      context "From a User Page" do
         it "lets a user delete their own comments" do
            user_comment.valid?
            visit(user_path(other_user))
            expect(page).to have_content(user_comment.contents)
            click_on("Delete Comment")
            expect(page).to have_current_path(user_path(other_user))
            expect(page).not_to have_content(user_comment.contents)
         end
      end
      context "From a Goal Page" do
         it "lets a user delete their own comments" do
            goal_comment.valid?
            visit(goal_path(token_goal))
            expect(page).to have_content(goal_comment.contents)
            click_on("Delete Comment")
            expect(page).to have_current_path(goal_path(token_goal))
            expect(page).not_to have_content(goal_comment.contents)
         end
      end

      let!(:other_users_goal_comment) { Comment.create!(contents:"I don't like this user.", author: other_user, commentable: token_goal)}
      let!(:other_users_user_comment) { Comment.create!(contents:"I don't like this goal.", author: other_user, commentable: main_user)}
      
      it "doesn't let a user delete other users' comments" do
         visit(goal_path(token_goal))
         expect(page).to have_content(other_users_goal_comment.contents)
         expect(page).not_to have_button("Delete Comment")

         visit(user_path(main_user))
         expect(page).to have_content(other_users_user_comment.contents)
         expect(page).not_to have_button("Delete Comment")
      end
   end


end
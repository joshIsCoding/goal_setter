require 'rails_helper'

RSpec.describe "User Authentication", type: :system do
   let(:user) { User.create!(username: "faked_user", password: "geronimo")}
   let(:other_user) { User.create!(username: "other_user", password: "drastic")}
   
   context "before registration" do
      it "asks the user to login if they try to access private content" do
         visit(user_path(user))
         expect(page).to have_content("Please login to view this page")
      end
   end

   describe "User Registration" do
      before(:each) { visit(new_user_path) }

      it "has a registration page" do
         expect(page).to have_content("Sign Up Here!")
      end

      describe "Using the Registration Form" do
         context "with valid user credentials" do
            it "shows the user's username on the homepage" do
               fill_in("user_username", with: "fake_user")
               fill_in("user_password", with: "wunderbar")
               click_on("Sign Up")
               expect(page).to have_content("fake_user")               
            end

         end

         context "with invalid user credentials" do
            it "refreshes the registration form with an error for another go" do
               fill_in("user_username", with: "fake_user")
               click_on("Sign Up")

               expect(page).to have_content("Sign Up Here!")
               expect(page).to have_content("too short")
            end
         end
      end
   end

   describe "User Login" do
      before(:each) { visit(new_session_path) }

      it "has a login page" do
         expect(page).to have_content("Login to Your Account")
      end

      describe "Using the Login Form" do
         context "with valid user credentials" do
            it "shows the user's username on the homepage" do
               fill_in("user_username", with: user.username)
               fill_in("user_password", with: user.password)
               click_on("Sign In")
               expect(page).to have_content(user.username)               
            end

         end

         context "with invalid user credentials" do
            it "refreshes the login page with an error for another go" do
               fill_in("user_username", with: user.username)
               click_on("Sign In")

               expect(page).to have_content("Login to Your Account")
               expect(page).to have_content("weren't valid")
            end
         end
      end

   end

   describe "User Privileges" do
      before(:each) do 
         visit(new_session_path)
         fill_in("user_username", with: user.username)
         fill_in("user_password", with: user.password)
         click_on("Sign In")
      end

      context "When logged in" do
      
         it "allows a user to see another user's public content only" do
            Goal.create!(title: "Private Goal", details: "Smashing life", user: other_user, public: false)
            Goal.create!(title: "Public Goal", details: "Smashing pumpkins", user: other_user, public: true)
            visit(user_path(other_user))
            expect(page).not_to have_content("Smashing life")
            expect(page).to have_content("Smashing pumpkins")
         end

         it "redirects to the user's page if a user tries to re-register without logging out first" do
            visit(new_user_path)
            expect(page).not_to have_content("Sign Up Here!")
         end

         it "redirects to the user's page if a user tries to re-login without logging out first" do
            visit(new_session_path)
            expect(page).not_to have_content("Login to Your Account")
         end

      end

      context "when a user logs out" do
         before { click_on("Logout") }

         it "strips their privileges" do
            expect(page).not_to have_content(user.username)
            visit(user_path(user))
            expect(page).to have_content("Please login to view this page")

         end
      end
   end
         

end
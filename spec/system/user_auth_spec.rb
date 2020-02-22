require 'rails_helper'

RSpec.describe "User Authentication", type: :system do
   let!(:user) { User.create!(username: "faked_user", password: "geronimo")}
   let!(:other_user) { User.create!(username: "other_user", password: "drastic")}
   let(:category) { [Category.create!(name: "Work")] }
   context "before registration" do
      let!(:goal) do 
         Goal.create!(
            user: other_user, 
            title: "Other User's Goal",
            categories: category,
            public: true
         )
      end
      before(:each) { visit(root_path) }
      
      it "allows the user to login or register from the home page" do
         within("section.unrecognised_user") do
            expect(page).to have_button("Log Back In")
            expect(page).to have_button("Create an Account")
         end
      end

      it "permits the user to visit the goal index without logging in" do
         within("header.site-header-bar nav") do
            click_on("Browse Goals")
         end
         expect(page).to have_current_path(goals_path)
         expect(page).to have_content("Browse All Goals")
      end

      context "Trying to Access Private Content" do

         it "asks the user to login if they try to access a user page" do
            within("section#leaderboards figure.users-leader-table") do
               click_on(other_user.username)
            end
            expect(page).to have_current_path(login_path)
            expect(page).to have_content("Please login to view this page")
         end

         it "asks the user to login if they try to access a goal page" do
            within("section#leaderboards") do
               click_on(goal.title)
            end
            expect(page).to have_current_path(login_path)
            expect(page).to have_content("Please login to view this page")
         end

         it "doesn't ask the user to login if they try to access the users index" do
            within("header.site-header-bar nav") do
               click_on("Browse Users")
            end
            expect(page).to have_current_path(users_path)
            expect(page).to have_content(user.username)
            expect(page).to have_content(other_user.username)
            
         end
      end
   end

   describe "User Registration" do
      before(:each) { visit(register_path) }

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
               expect(page).to have_current_path(root_path)             
            end

         end

         context "with invalid user credentials" do
            it "refreshes the registration form with an error for another go" do
               fill_in("user_username", with: "fake_user")
               click_on("Sign Up")

               expect(page).to have_content("Sign Up Here!")
               expect(page).to have_content("too short")
               expect(page).to have_current_path(users_path)
            end
         end
      end
   end

   describe "User Login" do
      before(:each) { visit(login_path) }

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
         visit(login_path)
         fill_in("user_username", with: user.username)
         fill_in("user_password", with: user.password)
         click_on("Sign In")
      end

      context "When logged in" do
      
         it "allows a user to see another user's public content only" do
            Goal.create!(
               title: "Private Goal", 
               details: "Smashing life", 
               user: other_user, 
               categories: category,
               public: false)
            Goal.create!(
               title: "Public Goal", 
               details: "Smashing pumpkins", 
               user: other_user, 
               categories: category,
               public: true)
            visit(user_path(other_user))
            expect(page).not_to have_content("Private Goal")
            expect(page).to have_content("Public Goal")
         end

         it "redirects to the home page if a user tries to re-register without logging out first" do
            visit(register_path)
            expect(page).not_to have_content("Sign Up Here!")
            expect(page).to have_current_path(root_path)
         end

         it "redirects to the home page if a user tries to re-login without logging out first" do
            visit(login_path)
            expect(page).not_to have_content("Login to Your Account")
            expect(page).to have_current_path(root_path)
         end

         context "Multiple Session Management" do
            let!(:sessions) do 
               sessions = []
               3.times{ sessions << Session.create!(user: user) }
               sessions
            end
            before(:each) { visit(account_sessions_path(user))}

            it "should show all active sessions for the user" do
               expect(page).to have_text("Your Active Sessions")
               within("table.sessions") do
                  expect(find_all("tr.remote_session").count).to eq(3)
               end
            end

            it "should allow the user to remotely logout of each session other than the current one" do
               find(".remote_session", match: :first)
               all(".remote_session").each do 
                  click_on("Delete Session", match: :first)
                  expect(page).to have_current_path(account_sessions_path(user))
               end
               expect(find("table.sessions"))
               .not_to have_button("Delete Session")
            end
         end
      end

      context "when a user logs out" do
         before do 
            find("ul.user-info .user-hover").hover
            click_on("Logout")
         end

         it "strips their privileges" do
            within("header.site-header-bar") do
               expect(page).not_to have_content(user.username)
            end
            visit(user_path(user))
            expect(page).to have_content("Please login to view this page")

         end
      end
   end
end
require 'rails_helper'

RSpec.describe "Using the Navigation Menu", type: :system do
   let(:main_user) { User.create!(username: "main", password:"mainpass") }

   it "should have the required navigation links" do
      visit(root_path)
      within("header#user_controls") do
         expect(page).to have_link "Home", href: /#{root_path}$/
         expect(find("nav")).to have_link "Browse Goals", href: /#{goals_path}$/
         expect(find("nav")).to have_link "Browse Users", href: /#{users_path}$/
      end
   end

   context "Before the User Logs In" do
      it "should not have a 'your profile' or manage account links" do
         visit(root_path)
         within("header#user_controls") do
            expect(find("nav")).to have_no_link(
               "Your Profile", 
               href: /#{user_path(main_user)}$/
            )
            expect(find("nav")).to have_no_link(
               "Manage Account", 
               href: /#{user_sessions_path(main_user)}$/
            )
         end
      end
   end

    context "After the User Logs In" do
      before do
         visit(new_session_path)
         fill_in("user_username", with: main_user.username)
         fill_in("user_password", with: main_user.password)
         click_on("Sign In")
      end

         it "should have 'your profile' and manage account links" do
         within("header#user_controls") do
            expect(find("nav")).to have_link(
               "Your Profile", 
               href: /#{user_path(main_user)}$/
            )
            expect(find("nav")).to have_link(
               "Manage Account", 
               href: /#{user_sessions_path(main_user)}$/
            )
         end
      end
   end
end
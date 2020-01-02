require 'rails_helper'

RSpec.describe "User Authentication", type: :system do
   describe "User Registration" do
      it "has a registration page" do
      visit(new_user_path)
      expect(page).to have_content("Sign Up Here!")
   end

      describe "Using the Registration Form" do
         context "with valid user credentials" do
            it "shows the user's username on the homepage" do
               fill_in('user_username', with: "fake_user")
               fill_in('user_password', with: "wunderbar")
               click_on('Sign Up')
               expect(page).to have_content("fake_user")               
            end

         end

         context "with invalid user credentials" do
            it "refreshes the registration form for another go" do
               fill_in('user_username', with: "fake_user")
               click_on('Sign Up')
               expect(page).to have_content("Sign Up Here!")
            end
         end
      end
   end
end
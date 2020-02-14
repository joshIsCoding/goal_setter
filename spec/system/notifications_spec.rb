require 'support/auth_helper'
require 'rails_helper'

RSpec.configure do |c|
  c.include AuthHelper
end

RSpec.describe "Receiving, Viewing and Generating Notifications", type: :system do
  let(:main_user) { User.create!(username: "main_user", password: "password")}
  let(:other_user) { User.create!(username: "other", password:"otherpass") }
  let(:category) { [Category.create!(name: "Work")] }
  let(:goal) do
      Goal.create!(title: "The goal", categories: category, user: main_user) 
  end
  let(:key_event) do 
    KeyEvent.create!(
      eventable: goal, 
      instigator: other_user,
      event_type: "update"
    )
  end  

  describe "Receiving and Viewing Notifications" do
    before(:each) do
      login(other_user)
      visit(goal_path(goal))
      find("form.upvote input[type=\"submit\"]").click
      find("ul.user-info li.user-hover").hover
      click_on("Logout")
      login(main_user)
    end
    it "displays the unseen notification count" do
      expect(find("span.notification-count")).
      to have_content("1")
    end
    it "shows the new notification in the dropdown menu"
    it "lets the user visit the record to which the notification refers"
  end

end
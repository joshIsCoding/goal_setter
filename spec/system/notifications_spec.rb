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
  let(:upvote) { UpVote.create!(goal: goal, user: other_user) }
  
  describe "Notification Index" do
    let!(:users) do
      (0..2).to_a.map do |i|
        User.create!(username: "user-#{i}", password: "password")
      end
    end
    let!(:upvotes) do 
      users.map do |user|
        UpVote.create!(goal: goal, user: user)
      end 
    end
  
    before(:each) { login(main_user) }
    it "should link to the notification index in the notification menu" do
      find(".notifications-hover").hover
      click_on("View all notifications")
      expect(page).to have_current_path(notifications_path)
    end

    it "should show all the user's notifications" do
      visit(notifications_path)
      users.each{ |user| expect(page).to have_content(user.username) }
      expect(find("main")).to have_content("upvoted your goal", count: 3)
    end
    it "should provide the option to mark all notifications as 'seen'"
  end

  describe "New Upvote Notifications" do
    describe "Receiving and Viewing Notifications" do
      before(:each) do
        login(other_user)
        visit(goal_path(goal))
        find("form.upvote button").click
        find("ul.user-info .user-hover").hover
        click_on("Logout")
        login(main_user)
      end
      it "displays the unseen notification count" do
        expect(find("strong.notification-count")).to have_content("1")
      end
      it "shows the new notification in the dropdown menu" do
        find(".notifications-hover").hover
        expect(page).
        to have_content("just upvoted your goal")
      end
      it "lets the user visit the record to which the notification refers" do
        find("a.notifications-hover").hover
        click_on("other just upvoted your goal")
        expect(page).to have_current_path(goal_path(goal))
        expect(page).to have_content(goal.title)
      end
      it "after viewing, it marks the notification as seen and reduces the unseen count" do
        find("a.notifications-hover").hover
        click_on("other just upvoted your goal")
        #strong.notification-count is empty when the notification count is 0; this
        #seems to cause issues for capybara, hence the use of the parent selector here
        expect(find("li.notifications")).not_to have_content("1")
      end
    end
  end

  describe "Updated Goal Notifications" do
    before(:each) do
      upvote.valid?
      login(main_user)
      visit(edit_goal_path(goal))
      fill_in("goal[title]", with: "I've updated my goal!")
      click_on("Save!")
      find("ul.user-info .user-hover").hover
      click_on("Logout")
      login(other_user)
    end
    it "shows the new notification in the dropdown menu" do
      find(".notifications-hover").hover
      expect(page).
      to have_content("main_user has updated their goal.")
    end
    it "lets the user visit the record to which the notification refers" do
      find(".notifications-hover").hover
      click_on("main_user has updated their goal.")
      expect(page).to have_current_path(goal_path(goal))
      expect(page).to have_content("I've updated my goal!")
    end
  end

  describe "New Comment Notifications" do
    context "when one user has comments after another on a goal" do
      let!(:comment) do 
        Comment.create!(
          contents: "first comment!", 
          author: other_user,
          commentable: goal
        )
      end
      before(:each) do
        login(main_user)
        visit(goal_path(goal))
        fill_in("comment_contents", with: "second comment!")
        click_on("Comment")
        find("ul.user-info .user-hover").hover
        click_on("Logout")
        login(other_user)
      end
      it "shows the new notification in the dropdown menu" do
        find(".notifications-hover").hover
        expect(page).
        to have_content("main_user commented after you.")
      end
      it "lets the user visit the record to which the notification refers" do
        find(".notifications-hover").hover
        click_on("main_user commented after you.")
        expect(page).to have_current_path(goal_path(goal))
        expect(page).to have_content("second comment!")
      end
    end

    context "when one user comments after another on a user profile" do
      let!(:comment) do 
        Comment.create!(
          contents: "first comment!", 
          author: other_user,
          commentable: main_user
        )
      end
      before(:each) do
        login(main_user)
        visit(user_path(main_user))
        fill_in("comment_contents", with: "second comment!")
        click_on("Comment")
        find("ul.user-info li.user-hover").hover
        click_on("Logout")
        login(other_user)
      end
      it "shows the new notification in the dropdown menu" do
        find(".notifications-hover").hover
        expect(page).
        to have_content("main_user commented after you.")
      end
      it "lets the user visit the record to which the notification refers" do
        find(".notifications-hover").hover
        click_on("main_user commented after you.")
        expect(page).to have_current_path(user_path(main_user))
        expect(page).to have_content("second comment!")
      end
    end
  end
end
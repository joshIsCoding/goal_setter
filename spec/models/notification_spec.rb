require 'rails_helper'

RSpec.describe Notification, type: :model do
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
  subject(:notification) { Notification.create!(key_event: key_event, user: main_user) }
  describe "Validations" do 
    it { should validate_uniqueness_of(:key_event_id).scoped_to(:user_id) }
  end

  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:key_event) }
  end

  describe "Notification Generation" do
    context "when there is a new upvote" do
      it "should generate a notification for the user whose goal was upvoted" do
        expect(main_user.notifications).to be_empty
        upvote = UpVote.create!(goal: goal, user: other_user)
        expect(main_user.notifications.count).to eq(1)
        key_event = main_user.notifications.first.key_event
        expect(key_event.eventable).to eq(upvote)
      end
    end

    context "when a goal is updated" do
      it "should generate notifications for all users who upvoted the goal"
    end
    
    context "when a comment is added" do
      it "should notify the user who received the comment or owns the commented goal"
      it "should notify all previous commenters"
    end
  end
end

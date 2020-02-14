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
    it { should have_one(:source) }
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

    let(:users) do
      [
        other_user,
        User.create!(username: "other_user_2", password: "password"),
        User.create!(username: "other_user_3", password: "password")
      ]
    end

    context "when a goal is updated" do
      it "should generate notifications for all users who upvoted the goal" do
        upvotes = users.map do |user| 
          UpVote.create!(user: user, goal: goal)
        end
        expect(users.inject([]){ |combined, user| combined + user.notifications}).
        to be_empty
        goal.title = "Updated Title"
        goal.save!
        users.each do |user|
          user.reload
          expect(user.notifications.count).to eq(1)
          key_event = user.notifications.first.key_event
          expect(key_event.eventable).to eq(goal)
          expect(key_event.instigator).to eq(main_user)
        end
      end
    end
    
    context "when a comment is added" do
      it "should notify the user who received the comment or owns the commented goal" do
        indir_comment = Comment.create!(
          contents: "comment", 
          commentable: goal, 
          author: other_user
        )
        expect(main_user.notifications.last.key_event.eventable).to eq(indir_comment)
        dir_comment = Comment.create!(
          contents: "comment", 
          commentable: main_user, 
          author: other_user
        )
        expect(main_user.notifications.last.key_event.eventable).to eq(dir_comment)
      end
      it "should notify all previous commenters" do
        users.each_with_index do |user, i|
          comment = Comment.create!(
            contents: "comment", 
            commentable: goal, 
            author: user
          )
          users[0...i].each do |prior_comment_user|
            key_event = prior_comment_user.notifications.last.key_event
            expect(key_event.eventable).to eq(comment)
            expect(key_event.instigator).to eq(user)
          end
        end
      end
    end
  end
end

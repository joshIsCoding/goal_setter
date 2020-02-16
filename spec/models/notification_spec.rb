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
    it { should have_one(:instigator) }
    it { should have_one(:upvote) }
    it { should have_one(:goal) }
    it { should have_one(:comment) }
  end

  describe "Notification Generation" do
    context "when there is a new upvote" do
      it "should generate a notification for the user whose goal was upvoted" do
        expect(main_user.notifications).to be_empty
        upvote = UpVote.create!(goal: goal, user: other_user)
        expect(main_user.notifications.count).to eq(1)
        notification = main_user.notifications.first
        expect(notification.upvote).to eq(upvote)
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
          notification = user.notifications.first
          expect(notification.goal).to eq(goal)
          expect(notification.instigator).to eq(main_user)
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
        expect(main_user.notifications.first.comment).to eq(indir_comment)
        dir_comment = Comment.create!(
          contents: "comment", 
          commentable: main_user, 
          author: other_user
        )
        expect(main_user.notifications.first.comment).to eq(dir_comment)
      end
      it "should notify all previous commenters" do
        users.each_with_index do |user, i|
          comment = Comment.create!(
            contents: "comment", 
            commentable: goal, 
            author: user
          )
          users[0...i].each do |prior_comment_user|
            notification = prior_comment_user.notifications.first
            expect(notification.comment).to eq(comment)
            expect(notification.instigator).to eq(user)
          end
        end
      end
      it "should not notify a user of their own comments" do
        2.times do 
          Comment.create!(
            contents: "comment",
            commentable: goal,
            author: other_user
          )
        end
        expect(other_user.notifications).to be_empty
      end
    end
  end
end

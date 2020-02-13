require 'rails_helper'

RSpec.describe KeyEvent, type: :model do
  describe "Validations" do
    it do 
      should validate_inclusion_of(:event_type).
      in_array(["new", "update"])
    end
  end

  describe "Associations" do
    it { should belong_to(:eventable) }
    it { should belong_to(:instigator) }
    it { should have_many(:notifications).dependent(:destroy) }
  end

  describe "Key Event Generation" do
    let(:main_user) { User.create!(username: "main", password:"mainpass") }
    let(:other_user) { User.create!(username: "other", password:"otherpass") }
    let(:category) { [Category.create!(name: "Work")] }
    let(:goal) do
        Goal.create!(title: "The goal", categories: category, user: main_user) 
    end
    let(:comment) do 
      Comment.new(
        contents: "New comment!", 
        author: other_user,
        commentable: goal
      )
    end


    context "For Upvotes" do
      let(:upvote) { UpVote.new(goal: goal, user: other_user) }
      it "should generate an event for new upvotes" do
        expect(KeyEvent.all).to be_empty
        upvote.save!
        expect(upvote.key_events.count).to eq(1)
      end
      it "should have the correct attributes" do
        upvote.save!
        key_event = upvote.key_events.first
        expect(key_event.instigator).to eq(other_user)
        expect(key_event.event_type).to eq("new")
        expect(key_event.notifications_generated).to be false
      end
    end

    context "For Goals" do
      it "should generate an event for updated goals" do
        expect(goal.key_events).to be_empty        
        goal.title = "Updated Goal"
        goal.save!
        expect(goal.key_events.count).to eq(1)
      end
      it "should have the correct attributes" do
        goal.title = "Updated Goal"
        goal.save!
        key_event = goal.key_events.first
        expect(key_event.instigator).to eq(main_user)
        expect(key_event.event_type).to eq("update")
        expect(key_event.notifications_generated).to be false
      end   
    end
    context "For Comments" do
      it "should generate an event for new comments" do
        expect(KeyEvent.all).to be_empty
        comment.save!
        expect(comment.key_events.count).to eq(1)
      end
      it "should have the correct attributes" do
        comment.save!
        comment_event = comment.key_events.first
        expect(comment_event.instigator).to eq(other_user)
        expect(comment_event.event_type).to eq("new")
        expect(comment_event.notifications_generated).to be false
      end
    end
  end
end

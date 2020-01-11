require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { User.new(username: "test_user", password: "test_pass") }

  describe "validations" do
    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username) }
    it { should validate_presence_of(:password_digest) }
    it { should validate_length_of(:password).is_at_least(5) }
    it { should allow_value(nil).for(:password) }
  end

  describe "associations" do
    it { should have_many(:goals).dependent(:destroy) }
    it { should have_many(:comments) }
    it { should have_many(:authored_comments).dependent(:destroy) }
    it { should have_many(:up_votes).dependent(:destroy) }
    it { should have_many(:up_voted_goals) }
    it { should have_many(:received_up_votes) }
  end

  describe "model methods" do
    before(:each) { user.save!}
    
    describe("Session token callback") do
      it "should ensure a session_token is set upon create" do
        expect(user.session_token).not_to be nil
      end
    end

    describe "::find_by_credentials(username, password)" do      
      context "when valid credentials are provided" do
        it "returns the correct user" do
          expect(User.find_by_credentials("test_user", "test_pass")).to eq(user)
        end
      end
      
      context "when invalid credentials are provided" do
        it "returns nil" do
          expect(User.find_by_credentials("test_user", "wrong_pass")).to be nil
          expect(User.find_by_credentials("no_user", "any_pass")).to be nil
        end
      end

    end

    describe "#reset_session_token!" do
      it "changes the session_token in the database" do
        old_token = user.session_token
        user.reset_session_token!
        user.valid?
        expect(user.session_token).not_to eq(old_token)
      end

    end

    describe "#is_password?(password)" do
      it "returns true when the provided password matches the user's password" do
        expect(user.is_password?("test_pass")).to be true
      end

      it "returns false when the provided password doesn't match the user's password" do
        expect(user.is_password?("other_password")).to be false
      end
    end

    describe "#add_up_vote(goal)" do
      
      let(:other_user) { User.create!(username: "otherUser", password: "otherpass") }
      let(:other_goal) { Goal.create!(title:"Test Goal", user: other_user) }
      let(:users_goal) { Goal.create!(title:"Main User's Goal", user: user) }

      it "should add an up-vote join record for the user and the goal" do
        expect(user.up_votes).to be_empty
        user.add_up_vote(other_goal)
        
        expect(user.up_voted_goals).to contain_exactly(other_goal)
        expect(user.up_votes.count).to eq(1)
        
        up_vote = user.up_votes.first
        expect(up_vote.user).to eq(user)
      end

      it "returns true upon success" do
        expect(user.add_up_vote(other_goal)).to be true
      end

      

      context "Failure Scenarios" do

        it "doesn't let the user up-vote their own goals" do
          expect{user.add_up_vote(users_goal)}.not_to change{user.up_votes}
          expect{user.add_up_vote(users_goal)}.not_to change{user.up_voted_goals}
        end
      
      
        it "prevents a user from making more than 10 up-votes" do
          10.times do |i|
            user.add_up_vote(Goal.create!(title: "Goal ##{i}", user: other_user))
          end
          expect{user.add_up_vote(other_goal)}.not_to change{user.up_votes}
          expect{user.add_up_vote(other_goal)}.not_to change{user.up_voted_goals}
        end
        
        it "returns false upon failure" do
          expect(user.add_up_vote(users_goal)).to be false
        end
      
      end
    end

  end




end

require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { User.new(username: "test_user", password: "test_pass") }

  describe "validations" do
    it { should validate_presence_of(:username) }
    it do
      user.up_votes_left = 3
      user.save!
      should validate_uniqueness_of(:username)
    end 
    it { should validate_presence_of(:password_digest) }
    it { should validate_length_of(:password).is_at_least(5) }
    it { should allow_value(nil).for(:password) }
    it do 
      should validate_numericality_of(:up_votes_left).only_integer
      .is_greater_than_or_equal_to(0).on(:create)
    end
  end

  describe "associations" do
    it { should have_many(:goals).dependent(:destroy) }
    it { should have_many(:sessions).dependent(:destroy) }
    it { should have_many(:comments) }
    it { should have_many(:authored_comments).dependent(:destroy) }
    it { should have_many(:up_votes).dependent(:destroy) }
    it { should have_many(:up_voted_goals) }
    it { should have_many(:received_up_votes) }
    it do 
      should have_many(:triggered_events).class_name("KeyEvent").
      dependent(:destroy) 
    end
    it { should have_many(:notifications).dependent(:destroy) }
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

    describe "#increment_up_votes_left!" do
      it "increases up_votes_left by one" do
        expect{user.increment_up_votes_left!}.to change{ user.up_votes_left }
        .from(UpVote::UP_VOTE_LIMIT).to(UpVote::UP_VOTE_LIMIT + 1)
      end
    end

    describe "#decrement_up_votes_left!" do
      it "decreases up_svotes_left by one" do
        expect{user.decrement_up_votes_left!}.to change{ user.up_votes_left }
        .from(UpVote::UP_VOTE_LIMIT).to(UpVote::UP_VOTE_LIMIT - 1)
      end
    end

    describe "#has_up_votes_remaining?" do
      
      it "returns true if the user has up_votes_left greater than zero" do
        expect(user.up_votes_left).to eq(UpVote::UP_VOTE_LIMIT)
        expect(user.has_up_votes_remaining?).to be true
      end
      
      it "returns false if the user has zero up_votes_left" do
        UpVote::UP_VOTE_LIMIT.times { user.decrement_up_votes_left! }
        expect(user.has_up_votes_remaining?).to be false
      end

    end

    describe "Query Methods" do
      # Users
      let!(:user_2) { User.create!(username: "user_2", password: "2_password") }
      let!(:user_3) { User.create!(username: "New Person", password: "new_pass") }
      # User Goals
      let!(:user_goal_A) do 
        Goal.create!(
          title: "Be Better!", 
          user: user, 
          status: "Complete"
          ) 
      end
      let!(:user_goal_B) do 
        Goal.create!(
          title: "Be Better Still!", 
          user: user, 
          status: "Complete"
          ) 
      end
      let!(:user_2_goal_A) do
        Goal.create!(
          title: "Less Worthy Goal", 
          user: user_2,
          status: "Complete"
        ) 
      end
      let!(:user_2_goal_B) { Goal.create!(title: "Worthy Goal", user: user_2) }
      let!(:user_2_goal_C) { Goal.create!(title: "Worthiest Goal", user: user_2) }
      # User Upvotes
      let!(:user_1_upvote_B) { UpVote.create!(goal: user_2_goal_B, user: user) }
      let!(:user_1_upvote_C) { UpVote.create!(goal: user_2_goal_C, user: user) }
      let!(:user_3_upvote_C) { UpVote.create!(goal: user_2_goal_C, user: user_3) }

      describe "#goals_with_up_votes" do    
        
        it "returns a sorted relation of the user's goals by creation time" do          
          user_goals = [user_goal_A, user_goal_B]
          user_2_goals = [user_2_goal_A, user_2_goal_B, user_2_goal_C]
          expect(user.goals_with_up_votes).to match_array(user_goals)
          expect(user_2.goals_with_up_votes).to match_array(user_2_goals)
        end

        it "returns goals with 'up_vote_count' properties" do
          user_2.goals_with_up_votes.each_with_index do |goal, i|
            expect(goal).to respond_to(:up_vote_count)
            expect(goal.up_vote_count).to eq(i)
          end
        end

        it "doesn't raise an error when treated like an enumerable but user has no goals" do
          expect{user_3.goals_with_up_votes.each}.not_to raise_error
        end
      end

      describe "::leaderboard" do
      
        it "returns users sorted by their completed goal count in descending order" do
          users = [user, user_2, user_3]
          expect(User.leaderboard).to eq(users)
        end

        it "has goal_count available as a property to the user objects" do
          most_goal_user = User.leaderboard.first
          expect(most_goal_user.goal_count).to be 2
        end

        it "has goal_completion_rate available as a property to the user objects" do
          users = User.leaderboard
          expect(users[0].goal_completion_rate).to eq(100)
          expect(users[1].goal_completion_rate).to eq(100/3)
          expect(users[2].goal_completion_rate).to eq(0)
        end


        it "returns no more than 10 users" do
          8.times { |i| User.create!(username: "#{i}-user", password: "#{i}_pass")}
          expect(User.leaderboard.length).to eq(10)
        end

      end

    end

  end




end

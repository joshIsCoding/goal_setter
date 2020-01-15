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



  end




end

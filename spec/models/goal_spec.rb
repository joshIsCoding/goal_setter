require 'rails_helper'

RSpec.describe Goal, type: :model do
  let(:user_1) { User.create!(username: "user_1", password: "1_password")}
  subject(:base_goal) { Goal.new(title: "Be Better!", user: user_1) }
  describe "validations" do

    it { should validate_presence_of(:title) }
    it do  
      should validate_inclusion_of(:status)
        .in_array ["Not Started", "In Progress", "Complete"] 
    end
    it { should validate_uniqueness_of(:title).scoped_to(:user_id) }
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:comments) }
    it { should have_many(:up_votes).dependent(:destroy) }
  end

  describe "methods" do
    describe "#get_up_vote(user)" do

      it "returns nil when the goal does not have an existing upvote by the provided user" do
        expect(base_goal.get_up_vote(user_1)).to be nil
      end
      
      it "returns the upvote by the provided user if it exists" do
        user_2 = User.create!(username: "user_2", password: "2_password")
        user_2_goal = Goal.create!(title: "Worthy Goal", user: user_2)
        user_1_upvote = UpVote.create!(goal: user_2_goal, user: user_1) 
        expect(user_2_goal.get_up_vote(user_1)).to eq(user_1_upvote)
      end
    end
  end

end

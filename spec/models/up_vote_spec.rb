require 'rails_helper'

RSpec.describe UpVote, type: :model do
  describe "Validations" do
    let(:user) { User.create!(username: "the_user", password: "user_pass") }
    let(:other_user) { User.create!(username: "other_user", password: "other_user_pass") }
    
    it do 
      unique_up_vote = UpVote.create!(user_id: user.id, goal: Goal.create!(title: "unique goal", user: user))
      should validate_uniqueness_of(:goal_id).scoped_to(:user_id)
    end

    it "does not permit more than the defined maximum up-votes per user" do
          UpVote::UP_VOTE_LIMIT.times do |i|
            UpVote.create!(
              user: user, 
              goal: Goal.create!(title: "Goal ##{i}", user: other_user)
            )
          end
          last_up_vote = UpVote.new(
              user: user,
              goal: Goal.create!(title: "Goal ##{UpVote::UP_VOTE_LIMIT + 1}", user: other_user)
            )
          expect(last_up_vote).not_to be_valid
    end
  end

  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:goal) }
  end
end

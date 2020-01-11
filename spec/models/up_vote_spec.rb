require 'rails_helper'

RSpec.describe UpVote, type: :model do
  describe "Validations" do
    let(:unique_up_vote) { Upvote.create!(user_id: 1, :goal_id: 1) }
    it { should validate_uniqueness_of(:goal_id).scoped_to(:user_id)}
  end

  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:goal) }
  end
end

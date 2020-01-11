require 'rails_helper'

RSpec.describe UpVote, type: :model do
  describe "Validations" do
    it { should validate_uniqueness_of(:goal_id).scoped_to(:goal_id)}
  end

  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:goal) }
  end
end

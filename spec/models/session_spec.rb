require 'rails_helper'

RSpec.describe Session, type: :model do
  describe "Validations" do
    it { should validate_presence_of(:session_token) }
    it { should validate_uniqueness_of(:session_token) }
  end

  describe "Associations" do
    it { should belong_to(:user) }
  end
end

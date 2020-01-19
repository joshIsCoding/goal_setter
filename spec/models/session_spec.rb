require 'rails_helper'

RSpec.describe Session, type: :model do
  describe "Validations" do
    subject(:unique_session) do
      Session.create!(
        user: User.create!(username: "test", password: "test_pass"), 
        session_token: Session.generate_session_token
      )
    end
    it { should validate_presence_of(:session_token) }
    it { should validate_uniqueness_of(:session_token) }
  end

  describe "Associations" do
    it { should belong_to(:user) }
  end
end

require 'rails_helper'

RSpec.describe Session, type: :model do
  let(:user) { User.create!(username: "test", password: "test_pass") }
  
  describe "Validations" do
    subject(:unique_session) do
      Session.create!(
        user: user, 
        session_token: Session.generate_session_token
      )
    end
    it { should validate_presence_of(:session_token) }
    it { should validate_uniqueness_of(:session_token) }
  end

  describe "Associations" do
    it { should belong_to(:user) }
  end

  describe "Methods" do
    
    describe("Session token callback") do
      it "should ensure a session_token is set after initialize" do
        new_session = Session.new(user: user)
        expect(new_session.session_token).not_to be nil
        expect{new_session.save!}.not_to raise_error
      end
    end
    
  end
end

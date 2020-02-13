require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:main_user) { User.create!(username: "main_user", password: "password")}
  let(:other_user) { User.create!(username: "other", password:"otherpass") }
  let(:category) { [Category.create!(name: "Work")] }
  let(:goal) do
      Goal.create!(title: "The goal", categories: category, user: main_user) 
  end
  let(:key_event) do 
    KeyEvent.create!(
      eventable: goal, 
      instigator: other_user,
      event_type: "update"
    )
  end  
  subject(:notification) { Notification.create!(key_event: key_event, user: main_user) }
  describe "Validations" do 
    it { should validate_uniqueness_of(:key_event_id).scoped_to(:user_id) }
  end

  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:key_event) }
  end

  
end

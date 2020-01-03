require 'rails_helper'

RSpec.describe Goal, type: :model do
  subject(:base_goal) { Goal.new(title: "Be Better!", user_id: 1) }
  describe "validations" do
    

    it { should validate_presence_of(:title) }
    
    it do  
      should validate_inclusion_of(:status)
        .in_array ["Not Started", "In Progress", "Complete"] 
    end

    it { should validate_uniqueness_of(:title).scoped_to(:user_id)}
  end

  describe "associations" do
    it { should belong_to(:user) }
  end

end

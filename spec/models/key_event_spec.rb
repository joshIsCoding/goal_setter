require 'rails_helper'

RSpec.describe KeyEvent, type: :model do
  describe "Validations" do
    it do 
      should validate_inclusion_of(:type).
      in_array(["new", "update"])
    end
  end

  describe "Associations" do
    it { should belong_to(:eventable) }
    it { should belong_to(:instigator) }
  end
end

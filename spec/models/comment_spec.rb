require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe "Validations" do
    it { should validate_presence_of(:contents) }
    it { should validate_length_of(:contents).is_at_most(1000) }
  end
end

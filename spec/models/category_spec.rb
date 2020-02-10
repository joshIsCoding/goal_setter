require 'rails_helper'

RSpec.describe Category, type: :model do
  describe "Validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "Associations" do
    it { is_expected.to have_and_belong_to_many(:goals) }
  end
  
end

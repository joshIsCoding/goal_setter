FactoryBot.define do
  factory :goal do
    title { "MyString" }
    details { "MyText" }
    status { "MyString" }
    public { false }
    user_id { "MyString" }
  end
end

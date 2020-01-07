FactoryBot.define do
  factory :comment do
    contents { "MyText" }
    commentable { nil }
  end
end

FactoryBot.define do
  factory :notification do
    user { nil }
    key_event { nil }
    seen { false }
  end
end

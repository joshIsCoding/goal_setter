FactoryBot.define do
  factory :key_event do
    eventable { nil }
    type { "" }
    instigator { nil }
    notifications_generated { false }
  end
end

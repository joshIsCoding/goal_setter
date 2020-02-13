FactoryBot.define do
  factory :key_event do
    eventable { nil }
    event_type { "" }
    instigator { nil }
    notifications_generated { false }
  end
end

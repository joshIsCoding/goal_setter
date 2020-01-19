FactoryBot.define do
  factory :session do
    session_token { "MyString" }
    user { nil }
    remote_ip { "MyString" }
    user_agent { "MyString" }
  end
end

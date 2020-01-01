FactoryBot.define do
  factory :user do
    username { "MyString" }
    password { "MyString" }
    password_digest { "MyString" }
    session_token { "MyString" }
  end
end

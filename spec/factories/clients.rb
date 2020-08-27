FactoryBot.define do
  factory :client do
    name { "MyString" }
    api_key { SecureRandom.base64(16) }
  end
end

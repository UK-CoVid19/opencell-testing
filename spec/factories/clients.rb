FactoryBot.define do
  sequence(:client_name) { |n| "Name#{n}" }

  factory :client do
    name { generate(:client_name) }
    api_key { SecureRandom.base64(16) }
  end
end

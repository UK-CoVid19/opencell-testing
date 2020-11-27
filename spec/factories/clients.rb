FactoryBot.define do
  sequence(:client_name) { |n| "Name#{n}" }

  factory :client do
    name { generate(:client_name) }
    api_key { SecureRandom.base64(16) }
    url { "https://blah.com"}
    headers { build_list(:header, 2)}
    labgroup { create(:labgroup) }
  end
end

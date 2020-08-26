FactoryBot.define do
  sequence :email do |n|
    "username#{n}@email.com"
  end

  factory :user do
    email {generate(:email)}
    password {"password"}
    password_confirmation {"password"}
    confirmed_at { DateTime.now}
    trait :patient do
      role { User.roles[:patient] }
      api_key { SecureRandom.base64(16) }
    end 
    role { User.roles[:patient]}
    api_key { SecureRandom.base64(16) }
    trait :staff do 
      role { User.roles[:staff]}
      api_key { nil }
    end 
  end
end
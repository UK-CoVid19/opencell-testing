FactoryBot.define do
  sequence :email do |n|
    "username#{n}@email.com"
  end

  factory :user do
    email {generate(:email)}
    password {"b]^$t&JF}?kN3Z5n"}
    password_confirmation {"b]^$t&JF}?kN3Z5n"}
    confirmed_at { DateTime.now}
    security_question { create(:security_question)}
    security_question_answer { "answer" }
    trait :patient do
      role { User.roles[:patient] }
    end 
    role { User.roles[:patient]}
    trait :staff do 
      role { User.roles[:staff]}
    end 
  end
end
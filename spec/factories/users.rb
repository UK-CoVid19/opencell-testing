FactoryBot.define do
  sequence :email do |n|
    "username#{n}@email.com"
  end

  factory :user do
    name { "Test Username" }
    dob  { Date.today }
    email {generate(:email)}
    password {"password"}
    password_confirmation {"password"}
    telno { 1234567 }
    confirmed_at { DateTime.now}
    role { User.roles[:patient]}
  end
end
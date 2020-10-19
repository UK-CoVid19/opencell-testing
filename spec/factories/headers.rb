FactoryBot.define do
  sequence :key do |n|
    "#{n}header"
  end

  factory :header do
    key { generate(:key) }
    value { "MyString" }
    client { nil }
  end
end

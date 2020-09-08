FactoryBot.define do
  sequence :name do |n|
    "question #{n}"
  end
  
  factory :security_question do
    locale { "MyString" }
    name { generate(:name) }
  end
end

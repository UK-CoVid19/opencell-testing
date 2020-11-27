FactoryBot.define do
  factory :labgroup do
    name { "MyString" }

    after(:create) do |labgroup|
      create_list(:lab, 1, labgroup: labgroup)
    end
  end
end

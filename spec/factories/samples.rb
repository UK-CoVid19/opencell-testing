FactoryBot.define do
  sequence(:uid) { |n| n }

  factory :sample do
    state { Sample.states[:preparing] }
    client { create(:client) }
    uid { generate(:uid) }
    created_at { DateTime.now }
  end
end

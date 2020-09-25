FactoryBot.define do
  sequence(:uid) { |n| n }

  factory :sample do
    state { Sample.states[:requested] }
    client { create(:client) }
    uid { generate(:uid) }
    created_at { DateTime.now }
    is_retest { false }
  end
end
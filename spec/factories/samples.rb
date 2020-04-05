FactoryBot.define do
  factory :sample do
    state { Sample.states[:requested]}
    user { create(:user) }
  end
end
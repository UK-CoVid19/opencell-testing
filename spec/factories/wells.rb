FactoryBot.define do

  sequence(:row, ('A'..'H').cycle) { |n| n }
  sequence(:column, (1..12).cycle) { |n| n }
  factory :well do
    row { generate(:row)}
    column { generate(:column) }
  end

end
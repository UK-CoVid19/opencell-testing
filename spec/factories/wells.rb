FactoryBot.define do

  sequence (:row) do |n|
    ('A'..'H').to_a[((n % 96)-1) / 12]
  end

  sequence (:column) do |n|
    (n % 12) + 1
  end

  factory :well do
    row { generate(:row) }
    column { generate(:column) }
  end

end
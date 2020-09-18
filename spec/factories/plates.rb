FactoryBot.define do
  factory :plate do
    state { Plate.states[:preparing] }
    transient do
      well_count  {96}
    end
    
    # after(:build) do |plate, evaluator|
    #   create_list(:well, evaluator.well_count, plate: plate)
    # end
  end
end
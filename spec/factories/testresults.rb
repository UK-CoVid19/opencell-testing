FactoryBot.define do
    factory :test_result do
      test { create(:test) }
      well { create(:well) }
      state { TestResult.states[:positive] }
    end
  end

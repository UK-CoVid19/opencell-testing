FactoryBot.define do
    factory :test do
      user { association :user }
      plate { association :plate }
      result_file { Rack::Test::UploadedFile.new("#{Rails.root}/spec/data/test1.csv", 'text/csv') }
    end
  end
  
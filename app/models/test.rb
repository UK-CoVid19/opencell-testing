class Test < ApplicationRecord
  belongs_to :plate
  belongs_to :user
  has_one_attached :result_file
  validates_presence_of :result_file
  validates_with AntivirusValidator, attribute_name: :result_file
  has_many :test_results, dependent: :destroy
  accepts_nested_attributes_for :test_results
end

class Test < ApplicationRecord
  belongs_to :plate
  belongs_to :user
  has_one_attached :result_file
  validates_uniqueness_of :plate_id
  validates :result_file, presence: true, blob: { content_type: ['text/csv', 'application/vnd.ms-excel'] }
  validates_with AntivirusValidator, attribute_name: :result_file
  has_many :test_results, dependent: :destroy
  accepts_nested_attributes_for :test_results
end

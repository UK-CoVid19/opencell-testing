class Test < ApplicationRecord
  belongs_to :plate
  belongs_to :user
  has_many_attached :result_files
  validates :result_files, length: {maximum: 2, minimum: 2 }
  has_many :test_results, dependent: :destroy
  accepts_nested_attributes_for :test_results
end

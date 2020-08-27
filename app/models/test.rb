class Test < ApplicationRecord
  belongs_to :plate
  belongs_to :user
<<<<<<< HEAD
  has_one_attached :result_file
=======
  has_many_attached :result_files
  validates :result_files, length: { maximum: 2, minimum: 2 }
>>>>>>> WIP split client model and user model
  has_many :test_results, dependent: :destroy
  accepts_nested_attributes_for :test_results
end

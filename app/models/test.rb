class Test < ApplicationRecord
  belongs_to :plate
  belongs_to :user
  has_one_attached :result_file

end

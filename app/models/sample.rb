class Sample < ApplicationRecord
  belongs_to :user

  enum state: %i[requested dispatched received preparing prepared tested analysed communicated]
end

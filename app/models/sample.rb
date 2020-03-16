class Sample < ApplicationRecord
  belongs_to :user

  enum state: %i[requested dispatched received preparing processed analysed communicated]
end

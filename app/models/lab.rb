class Lab < ApplicationRecord
  belongs_to :labgroup
  has_many :plates
end

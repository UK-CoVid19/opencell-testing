class Labgroup < ApplicationRecord
  has_and_belongs_to_many :labs
  has_many :clients
  has_and_belongs_to_many :users
  accepts_nested_attributes_for :labs
  accepts_nested_attributes_for :clients
  validates_presence_of :name
end

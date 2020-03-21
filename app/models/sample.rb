class Sample < ApplicationRecord
  belongs_to :user

  enum state: %i[requested dispatched received preparing prepared tested analysed communicated]

  scope :requested, -> {where(:state => Sample.states[:requested])}
  scope :dispatched, -> {where(:state => Sample.states[:dispatched])}
  scope :received, -> {where(:state => Sample.states[:received])}
  scope :preparing, -> {where(:state => Sample.states[:preparing])}
  scope :prepared, -> {where(:state => Sample.states[:prepared])}
  scope :tested, -> {where(:state => Sample.states[:tested])}
  scope :analysed, -> {where(:state => Sample.states[:analysed])}
  scope :communicated, -> {where(:state => Sample.states[:communicated])}
end

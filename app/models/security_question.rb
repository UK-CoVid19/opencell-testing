class SecurityQuestion < ApplicationRecord
  validates :locale, presence: true
  validates :name, presence: true, uniqueness: true
end

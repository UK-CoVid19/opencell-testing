class Header < ApplicationRecord
  include EncryptableModelConcern
  belongs_to :client
  validates :key, presence: true, uniqueness: { scope: :client }
  validates :value, presence: true
  encryptable_attributes :value
end

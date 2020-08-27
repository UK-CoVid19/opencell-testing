# frozen_string_literal: true

class Client < ApplicationRecord
  has_many :samples, dependent: :destroy
  has_one :test, dependent: :destroy

  before_create :hash_api_key

  attr_accessor :api_key

  def hash_api_key
    raise if api_key.blank?

    self.api_key_hash = Digest::SHA256.base64digest(api_key.encode('UTF-8'))
  end
end

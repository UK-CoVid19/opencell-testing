# frozen_string_literal: true

class Client < ApplicationRecord
  has_many :samples, dependent: :destroy

  validates :name, uniqueness: true
  before_create :hash_api_key

  attr_accessor :api_key

  def self.control_client
    c = find_by(name: CONTROL_NAME)
    c = Client.create!(name: CONTROL_NAME,api_key: SecureRandom.base64(16), notify: false) if c.nil?
    c
  end

  CONTROL_NAME = "control"
  INTERNAL_RERUN_NAME = 'Posthoc Retest'

  def hash_api_key
    raise "API key required" if api_key.blank?

    self.api_key_hash = Digest::SHA256.base64digest(api_key.encode('UTF-8'))
  end
end

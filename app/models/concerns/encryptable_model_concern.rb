require 'openssl'
require 'base64'

module EncryptableModelConcern
  extend ActiveSupport::Concern

  included do
    before_save :encrypt_encryptable_attributes
    after_save :decrypt_encryptable_attributes
    after_find :decrypt_encryptable_attributes
  end

  module ClassMethods
    # Sets the model `@encryptable_attributes` class instance variable.
    # Encryptable attributes are encrypted before saving using `before_save` hook and decrypted using `after_save` and `after_find` hooks.
    # Example:
    # ```
    #   class Board < BaseModel
    #     encryptable_attributes :name, :title, :content
    #   end
    # ```
    def encryptable_attributes(*attrs)
      @encryptable_attributes = attrs
    end
  end

  # Returns the model's `@encryptable_attributes` class instance variable.
  #
  def encryptable_attributes
    self.class.instance_variable_get(:@encryptable_attributes) || []
  end

  # Encryptes the model's encryptable attributes before saving using Rails' `before_save` hook.
  #
  # **Note: Be careful in calling this method manually as it can corrupt the data.**
  def encrypt_encryptable_attributes
    encryptable_attributes.each do |k|
      self[k] = encrypt(self[k])
    end
  end

  # Decrypts the model's encryptable attributes using Rails' `after_save` and `after_find` hooks.
  #
  # **Note: Be careful in calling this method manually as it can corrupt the data.**
  def decrypt_encryptable_attributes
    encryptable_attributes.each do |k|
      self[k] = decrypt(self[k])
    end
  end

  private

  def cipher
    OpenSSL::Cipher::Cipher.new('aes-256-cbc')
  end

  def cipher_key
    # Rails.configuration.crypto['key'] # <-- your own key generator here
    Rails.application.credentials.dig(:crypto, :key)
  end

  def encrypt(value)
    c = cipher.encrypt
    c.key = Digest::SHA256.digest(cipher_key)
    c.iv = iv = c.random_iv
    Base64.encode64(iv) + Base64.encode64(c.update(value.to_s) + c.final)
  end

  def decrypt(value)
    c = cipher.decrypt
    c.key = Digest::SHA256.digest(cipher_key)
    c.iv = Base64.decode64 value.slice!(0,25)
    c.update(Base64.decode64(value.to_s)) + c.final
  end

end

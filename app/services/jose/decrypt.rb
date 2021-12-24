class Jose::Decrypt < ApplicationService
  def initialize(encrypted_jwt)
    @encrypted_jwt = encrypted_jwt
    @encryption_key = Rails.application.secrets.jwt_encryption_key.stringify_keys
  end

  def perform
    @decrypted_jwt ||= JOSE::JWK.block_decrypt(
      JOSE::JWK.from_map(@encryption_key),
      JOSE::EncryptedBinary.new(@encrypted_jwt).expand
    ).first
  end

  def fields
    return unless @decrypted_jwt.present?
    @decrypted_jwt.fields.to_h.symbolize_keys
  end
end

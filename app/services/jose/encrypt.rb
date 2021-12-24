class Jose::Encrypt < ApplicationService
  def initialize(jwt)
    @jwt = jwt
    @encryption_key = Rails.application.secrets.jwt_encryption_key.stringify_keys
  end

  def perform
    JOSE::JWK.block_encrypt(JOSE::JWK.from_map(@encryption_key), @jwt).compact
  end
end

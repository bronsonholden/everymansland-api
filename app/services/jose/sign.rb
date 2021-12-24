class Jose::Sign < ApplicationService
  def initialize(payload)
    @payload = payload
    @signing_key = Rails.application.secrets.jwt_signing_key.stringify_keys
  end

  def perform
    JOSE::JWK.sign(@payload.to_json, JOSE::JWK.from_map(@signing_key)).compact
  end
end

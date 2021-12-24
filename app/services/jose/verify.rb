class Jose::Verify < ApplicationService
  def initialize(jwt)
    @jwt = jwt
    @signing_key = Rails.application.secrets.jwt_signing_key.stringify_keys
  end

  def perform
    result = JOSE::JWT.verify_strict(JOSE::JWK.from_map(@signing_key), ["HS256"], @jwt)
    return unless result[0]
    result[1].fields.to_h.symbolize_keys
  end
end

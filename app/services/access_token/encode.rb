class AccessToken::Encode < ApplicationService
  def initialize(user, claims = {})
    @user = user
    @claims = claims.symbolize_keys
    @claims[:exp] ||= exp
  end

  def perform
    signed = Jose::Sign.perform(@claims.merge({
      aud: @user.id.to_s,
      jti: SecureRandom.uuid
    }))

    Jose::Encrypt.perform(signed)
  end

  def exp
    1.hour.from_now.to_i
  end
end

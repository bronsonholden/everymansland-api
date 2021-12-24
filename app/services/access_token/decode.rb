class AccessToken::Decode < ApplicationService
  def initialize(jwt)
    @jwt = jwt
  end

  def perform
    decrypted_jwt = Jose::Decrypt.perform(@jwt)
    Jose::Verify.perform(decrypted_jwt)
  end
end

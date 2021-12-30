class SessionController < ApplicationController
  include ActionController::Cookies

  before_action :authenticate_user!, only: :destroy

  def create
    user = User.find_by(email: session_params[:email])
    raise NotFoundError.with(User, :email, session_params[:email]) unless user.present?
    unless user.password_digest? && user.authenticate(session_params[:password])
      raise UnauthorizedError.new("Incorrect password")
    end

    RefreshToken.where(user: user).delete_all
    token = SecureRandom.hex(32)
    user.refresh_tokens << RefreshToken.create(token: token)
    set_refresh_token_cookie(token)

    jwt = AccessToken::Encode.perform(user)
    render json: {jwt: jwt}, status: :created
  end

  def update
    refresh_token = RefreshToken
      .where(expires_at: Time.now..)
      .find_by(token: cookies.encrypted[:refresh_token])

    if refresh_token.nil?
      cookies.delete(
        :refresh_token,
        domain: cookie_domain
      )
      raise UnauthorizedError.new("Invalid refresh token")
    end

    set_refresh_token_cookie(refresh_token.token)
    jwt = AccessToken::Encode.perform(refresh_token.user)
    render json: {jwt: jwt}, status: :ok
  end

  def destroy
    payload = jwt_payload!
    BlacklistToken.create!(jti: payload[:jti], exp: Time.now)
    cookies.delete :refresh_token, domain: cookie_domain
  end

  private

  def cookie_domain
    # TODO
    "localhost"
  end

  def session_params
    params.require("session").permit(:email, :password)
  end

  def set_refresh_token_cookie(token)
    cookies.encrypted[:refresh_token] = {
      value: token,
      path: "/",
      httponly: true,
      domain: cookie_domain,
      secure: Rails.env.production?
    }
  end
end

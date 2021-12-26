class ApplicationController < ActionController::API
  def self.rescue_from(*args, **opts, &block)
    super(*args, **opts, &block) if Rails.env.production?
  end

  rescue_from StandardError, with: :render_errors
  rescue_from RailsParam::InvalidParameterError, with: :render_errors
  rescue_from ActiveRecord::RecordInvalid do |error|
    application_error(UnprocessableEntityError.new(error.record.errors.to_a))
  end
  rescue_from ActiveRecord::RecordNotFound do |error|
    application_error(NotFoundError.new("#{error.model} not found"))
  end
  rescue_from UnauthorizedError, with: :application_error
  rescue_from NotFoundError, with: :application_error

  attr_reader :current_user

  protected

  # I don't understand why these don't exist by default
  def path_params
    @path_params ||= ActionController::Parameters.new(request.path_parameters)
  end

  def query_params
    @query_params ||= ActionController::Parameters.new(request.query_parameters)
  end
  # ¯\_(ツ)_/¯

  def nyi!
    response.set_header("Cache-Control", "no-cache")
    head :not_implemented
  end

  def authenticate_user!
    payload = jwt_payload!
    raise UnauthorizedError.new("Expired access token") if Time.at(payload[:exp]).past?
    @current_user = User.find_by(id: payload[:aud])
    raise UnauthorizedError.new("Invalid access token") if @current_user.nil?
  end

  private

  def jwt!
    authorization = request.headers["Authorization"]
    res = authorization&.match(/\A[Bb]earer\s+(.+)\z/)
    raise UnauthorizedError.new("No access token provided") if res.nil?
    res[1]
  end

  def jwt_payload!
    payload = AccessToken::Decode.perform(jwt!)
    raise UnauthorizedError.new("Invalid access token") if payload.nil?
    raise UnauthorizedError.new("Blacklisted access token") if BlacklistToken.find_by(jti: payload[:jti])
    payload
  end

  def render_errors(error)
    render json: {
      errors: Array.wrap(error.message)
    }, status: :unprocessable_entity
  end

  def application_error(error)
    render json: {
      errors: Array.wrap(error.message)
    }, status: error.status
  end
end

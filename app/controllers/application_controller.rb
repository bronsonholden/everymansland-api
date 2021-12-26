class ApplicationController < ActionController::API
  def self.rescue_from(*args, **opts, &block)
    super(*args, **opts, &block) if Rails.env.production?
  end

  rescue_from StandardError, with: :render_errors
  rescue_from RailsParam::InvalidParameterError do |error|
    application_error(ApplicationError.new(error.message, :unprocessable_entity))
  end
  rescue_from ActiveRecord::RecordInvalid do |error|
    application_error(ApplicationError.new(error.record.errors.to_a, :unprocessable_entity))
  end
  rescue_from ActiveRecord::RecordNotFound do |error|
    application_error(ApplicationError.new("#{error.model} not found", :not_found))
  end
  rescue_from ApplicationError, with: :application_error

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
    raise ApplicationError.new("Expired access token", :unauthorized) if Time.at(payload[:exp]).past?
    @current_user = User.find_by(id: payload[:aud])
    raise ApplicationError.new("Invalid access token", :unauthorized) if @current_user.nil?
  end

  private

  def jwt!
    authorization = request.headers["Authorization"]
    res = authorization&.match(/\A[Bb]earer\s+(.+)\z/)
    raise ApplicationError.new("No access token provided", :unauthorized) if res.nil?
    res[1]
  end

  def jwt_payload!
    payload = AccessToken::Decode.perform(jwt!)
    raise ApplicationError.new("Invalid access token", :unauthorized) if payload.nil?
    raise ApplicationError.new("Blacklisted access token", :unauthorized) if BlacklistToken.find_by(jti: payload[:jti])
    payload
  end

  def application_error(error)
    render json: {
      error: Array.wrap(error.message).to_sentence
    }, status: error.status
  end
end

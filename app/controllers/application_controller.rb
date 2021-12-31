class ApplicationController < ActionController::API
  attr_reader :current_user

  rescue_from ApplicationError, with: :application_error if Rails.env.production?

  protected

  def query_params!
    ActionController::Parameters.new(request.query_parameters)
      .permit!
      .to_h
      .symbolize_keys
      .except(:page, :limit)
  end

  def nyi!
    response.set_header("Cache-Control", "no-cache")
    head :not_implemented
  end

  def peek_authenticate_user!
    authenticate_user! if request.headers["Authorization"].present?
  end

  def authenticate_user!
    payload = jwt_payload!
    raise UnauthorizedError.new("Expired access token") if Time.at(payload[:exp]).past?
    @current_user = User.find_by(id: payload[:aud])
    raise UnauthorizedError.new("Invalid access token") if @current_user.nil?
  end

  def serialize_collection(scope, paged: true)
    scope = if paged
      paging = params.permit!.to_h.symbolize_keys.slice(:page, :limit)
      Parameter::Validate.perform(paging, :page, Integer, range: (1..), default: 1)
      Parameter::Validate.perform(paging, :limit, Integer, range: (1..100), default: 25)
      scope.offset((paging[:page] - 1) * paging[:limit]).limit(paging[:limit])
    else
      scope
    end

    blueprint = begin
      "#{scope.model.to_s}Blueprint".constantize
    rescue NameError
      raise ApplicationError.new("No blueprint found for serialization")
    end

    {
      "#{scope.table_name}": blueprint.render_as_hash(scope),
      total: scope.offset(nil).limit(nil).count,
      page: (paging[:page] if paged)
    }.compact
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

  def application_error(error)
    render json: {
      error: Array.wrap(error.messages).to_sentence
    }, status: error.status
  end
end

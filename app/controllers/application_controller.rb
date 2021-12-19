class ApplicationController < ActionController::API
  rescue_from RailsParam::InvalidParameterError, with: :render_errors

  protected

  def nyi!
    response.set_header("Cache-Control", "no-cache")
    head :not_implemented
  end

  private

  def render_errors(error)
    render json: {
      errors: Array.wrap(error).map(&:message)
    }, status: :unprocessable_entity
  end
end

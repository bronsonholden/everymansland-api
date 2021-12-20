class ApplicationController < ActionController::API
  rescue_from RailsParam::InvalidParameterError, with: :render_errors
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

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

  def not_found(error)
    render json: {
      errors: ["Record not found"]
    }, status: :not_found
  end
end

class UnauthorizedError < ApplicationError
  def status
    :unauthorized
  end
end

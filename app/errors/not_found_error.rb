class NotFoundError < ApplicationError
  def status
    :not_found
  end
end

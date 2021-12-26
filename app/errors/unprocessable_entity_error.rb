class UnprocessableEntityError < ApplicationError
  def status
    :unprocessable_entity
  end
end

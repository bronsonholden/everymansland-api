class ForbiddenError < ApplicationError
  def self.no_permission(to_do)
    new("You do not have permission to #{to_do}")
  end
end

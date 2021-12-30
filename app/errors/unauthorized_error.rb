class UnauthorizedError < ApplicationError
  def self.login_required(to_do)
    new("You must log in to #{to_do}")
  end
end

class AuthenticatedUserController < ApplicationController
  before_action :authenticate_user!

  def show
    nyi!
  end

  def update
    nyi!
  end
end

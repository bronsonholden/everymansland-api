class UsersController < ApplicationController
  def index
    users = User.all

    render json: {
      count: users.size,
      users: UserBlueprint.render_as_hash(users)
    }, status: :ok
  end

  def show
    render json: {users: UserBlueprint.render_as_hash(User.find(params[:id]))}, status: :ok
  end

  def create
    nyi!
  end

  def update
    nyi!
  end
end

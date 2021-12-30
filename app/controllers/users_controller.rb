class UsersController < ApplicationController
  def index
    users = User.all

    render json: {
      total: users.size,
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

  def activities
    begin
      authenticate_user!
    rescue UnauthorizedError
    end

    user = begin
      User.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      raise NotFoundError.with(User, :id, user_id)
    end

    scope = Activity::List.exec(query_params!, {
      requesting_user: current_user,
      for_user: user
    })

    render json: {
      activities: ActivityBlueprint.render_as_hash(scope),
      total: scope.count,
      page: 1,
    }.compact, status: :ok
  end
end

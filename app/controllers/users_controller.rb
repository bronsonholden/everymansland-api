class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[add_friend friends remove_friend]
  before_action :set_user, only: %i[add_friend friends remove_friend]

  def index
    users = User.all

    render json: serialize_collection(users), status: :ok
  end

  def show
    user = begin
      User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      raise NotFoundError.with(User, :id, params[:id])
    end

    render json: UserBlueprint.render_as_hash(user), status: :ok
  end

  def create
    nyi!
  end

  def update
    nyi!
  end

  def add_friend
    current_user.friendships.first_or_create!(friend: @user)
    head :no_content
  end

  def remove_friend
    begin
      Friendship.find_by!(user: current_user, friend: @user).breakup
    rescue ActiveRecord::RecordNotFound => e
      raise NotFoundError.with(Friendship, :friend_id, @user.id)
    end
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
      current_user: current_user,
      for_user: user
    })

    render json: serialize_collection(scope), status: :ok
  end

  private

  def set_user
    begin
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      raise NotFoundError.with(User, :id, params[:id])
    end
  end
end

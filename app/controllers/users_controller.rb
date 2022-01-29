class UsersController < ApplicationController
  before_action :peek_authenticate_user, only: :activities
  before_action :authenticate_user!, only: %i[
    add_friend
    friends
    friend_requests
    remove_friend
  ]
  before_action :set_user, only: %i[
    activities
    add_friend
    friends
    friend_requests
    remove_friend
    show
  ]

  def index
    users = User.all

    render json: serialize_collection(users), status: :ok
  end

  def show
    render json: UserBlueprint.render_as_hash(@user), status: :ok
  end

  def create
    nyi!
  end

  def update
    nyi!
  end

  def add_friend
    begin
      Friendship.where(user: current_user, friend: @user).first_or_create!
    rescue ActiveRecord::RecordInvalid => e
      # In case additional validations beyond uniquness are added
      raise UnprocessableEntityError.from_record_invalid(e)
    end

    head :no_content
  end

  def remove_friend
    Friendship.between(current_user, @user).first&.breakup

    head :no_content
  end

  def activities
    scope = Activity::List.exec(query_params!, {
      current_user: current_user,
      for_user: @user
    })

    render json: serialize_collection(scope), status: :ok
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise NotFoundError.record_with_attribute_value(User, :id, params[:id])
  end
end

class AuthenticatedUserController < ApplicationController
  before_action :authenticate_user!

  def show
    render json: UserBlueprint.render(current_user), status: :ok
  end

  def update
    param! :first_name, String
    param! :last_name, String
    param! :condition, Hash do |condition|
      condition.param! :weight, Float, min: 0
    end

    current_user.update({
      first_name: user_params[:first_name],
      last_name: user_params[:last_name],
      condition_attributes: user_params[:condition].to_h,
    }.compact_blank)

    head :ok
  end

  private

  def user_params
    params.require(:authenticated_user).permit(
      :first_name,
      :last_name,
      condition: [:weight]
    )
  end
end

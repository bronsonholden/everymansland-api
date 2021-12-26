class AuthenticatedUserController < ApplicationController
  before_action :authenticate_user!

  def show
    render json: UserBlueprint.render(current_user), status: :ok
  end

  def update
    data = user_params.to_h.tap do |hash|
      hash[:condition_attributes] = hash.delete :condition
    end.compact_blank

    current_user.update!(data)
    head :ok
  end

  private

  def user_params
    params.require(:authenticated_user).permit(
      :first_name,
      :height,
      :last_name,
      :sex,
      condition: [:weight, :cycling_ftp]
    )
  end
end

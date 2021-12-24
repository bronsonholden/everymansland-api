class AvatarController < ApplicationController
  before_action :authenticate_user!

  def show
    head :not_found if current_user.avatar.blank?
    send_file current_user.avatar.download
  end

  def update
    avatar = params[:avatar]
    # TODO: raise ... unless avatar.present?
    current_user.update!(avatar: params[:avatar])
  end
end

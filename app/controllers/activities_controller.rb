class ActivitiesController < ApplicationController
  before_action :set_activity, only: %i[destroy show update snapshots]

  def create
    nyi!
  end

  def destroy
    nyi!
  end

  def index
    begin
      authenticate_user!
    rescue UnauthorizedError
    end

    scope = Activity::List.exec(query_params!, {
      current_user: current_user,
      for_user: nil
    })

    render json: {
      activities: ActivityBlueprint.render_as_hash(scope),
      total: scope.count,
      page: 1,
    }.compact, status: :ok
  end

  def show
    render json: ActivityBlueprint.render(@activity), status: :ok
  end

  def update
    nyi!
  end

  def snapshots
    param! :limit, Integer, min: 1, max: 100, default: 25, message: "limit must be between 1 and 100 inclusively"
    param! :t, Integer, min: 0, default: 0

    snapshots = @activity
      .snapshots
      .where("t >= ?", params[:t])
      .order(t: :asc)
      .limit(params[:limit])

    render json: {
      total: @activity.snapshots.count,
      snapshots: SnapshotBlueprint.render_as_hash(snapshots, view: @activity.sport)
    }, status: :ok
  end

  private

  def set_activity
    @activity = Activity.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    raise NotFoundError.with(Activity, :id, params[:id])
  end
end

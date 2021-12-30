class ActivitiesController < ApplicationController
  before_action :set_activity, only: %i[destroy show update snapshots]
  before_action :authenticate_user!, only: [:create, :destroy, :snapshots]

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
    snapshots = Snapshot::List.exec(query_params!, {
      current_user: current_user,
      for_activity: @activity
    })

    render json: {
      snapshots: SnapshotBlueprint.render_as_hash(snapshots, view: @activity.sport),
      total: snapshots.count
    }, status: :ok
  end

  private

  def set_activity
    @activity = Activity.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    raise NotFoundError.with(Activity, :id, params[:id])
  end
end

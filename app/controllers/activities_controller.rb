class ActivitiesController < ApplicationController
  before_action :set_activity, only: %i[destroy show update snapshots]

  def create
    nyi!
  end

  def destroy
    nyi!
  end

  def index
    param! :sort, String, in: %w[started_at created_at], default: "started_at"
    param! :direction, String, in: %w[asc desc], default: "desc"
    param! :sport, String, in: Activity::SUPPORTED_SPORT_TYPES.map(&:to_s)
    param! :page, Integer, min: 1, default: 1
    param! :limit, Integer, min: 1, max: 100, default: 25, message: "limit must be between 1 and 100 inclusively"

    user_id = path_params.permit(:user_id).fetch(:user_id, nil)

    activities = Activity.all
    activities = activities.where(user_id: user_id) unless user_id.nil?
    activities = activities
      .order({:"#{params[:sort]}" => params[:direction].to_sym})
      .offset((params[:page] - 1) * params[:limit])
    activities = activities.send(params[:sport].to_sym) if params[:sport].present?

    render json: {
      activities: ActivityBlueprint.render_as_hash(activities.limit(params[:limit])),
      count: Activity.all.count,
      page: params[:page]
    }, status: :ok
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
      count: @activity.snapshots.count,
      snapshots: SnapshotBlueprint.render_as_hash(snapshots, view: @activity.sport)
    }, status: :ok
  end

  private

  def set_activity
    @activity = Activity.find(params[:id])
  end
end

class ActivitiesController < ApplicationController
  before_action :set_activity, only: %i[destroy show update snapshots]
  before_action :authenticate_user!, except: :index

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

    render json: serialize_collection(scope), status: :ok
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

    # Snapshots are cursor-paged, so we only need to apply limit
    paging = params.permit!.to_h.symbolize_keys.slice(:limit)
    Parameter::Validate.perform(paging, :limit, Integer, range: (1..100), default: 25)

    render json: serialize_collection(
      snapshots.limit(paging[:limit]),
      paged: false
    ), status: :ok
  end

  private

  def set_activity
    @activity = Activity.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    raise NotFoundError.with(Activity, :id, params[:id])
  end
end

class ActivitiesController < ApplicationController
  before_action :set_activity, only: %i[destroy show update snapshots]
  before_action :authenticate_user!, except: %i[index show snapshots]
  before_action :peek_authenticate_user!, only: %i[index show snapshots]

  def create
    activity = current_user.activities.build(fit: params[:fit])

    begin
      activity.save!
    rescue ActiveRecord::RecordInvalid => e
      raise UnprocessableEntityError.from_record_invalid(e)
    end

    Activity::ProcessFit.delay.perform(activity)

    render json: ActivityBlueprint.render(activity), status: :accepted

  end

  def destroy
    unless current_user.activities.where(id: @activity.id).any?
      raise ForbiddenError.no_destroy_permission(@activity)
    end

    @activity.destroy

    head :no_content
  end

  def index
    scope = Activity::List.exec(query_params!, {
      current_user: current_user,
      for_user: nil
    })

    render json: serialize_collection(scope), status: :ok
  end

  def show
    unless Activity::List.exec(nil, {current_user: current_user}).where(id: @activity.id).any?
      raise ForbiddenError.no_show_permission(@activity)
    end

    render json: ActivityBlueprint.render(@activity), status: :ok
  end

  def update
    unless current_user.activities.where(id: @activity.id).any?
      raise ForbiddenError.no_update_permission(@activity)
    end

    Parameter::Validate.perform(
      activity_params.slice(:sport),
      :sport,
      String,
      in: Activity::SUPPORTED_SPORT_TYPES.map(&:to_s)
    )

    Parameter::Validate.perform(
      activity_params.slice(:visibility),
      :visibility,
      String,
      in: Activity.visibilities.keys
    )

    begin
      @activity.update!(activity_params)
    rescue ActiveRecord::RecordInvalid => e
      raise UnprocessableEntityError.from_record_invalid(e)
    end

    render json: ActivityBlueprint.render(@activity), status: :ok
  end

  def snapshots
    snapshots = Snapshot::List.exec(query_params!, {
      current_user: current_user,
      for_activity: @activity
    })

    # Snapshots are cursor-paged, so we only need to apply limit
    paging = params.permit!.to_h.symbolize_keys.slice(:limit)
    Parameter::Validate.perform(paging, :limit, Integer, range: (1..500), default: 100)

    render json: serialize_collection(
      snapshots.limit(paging[:limit]),
      paged: false,
      view: @activity.sport
    ).merge({
      remaining: snapshots.count
    }), status: :ok
  end

  private

  def set_activity
    @activity = Activity.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise NotFoundError.record_with_attribute_value(Activity, :id, params[:id])
  end

  def activity_params
    @activity_params ||= params.require(:activity).permit(
      :started_at,
      :sport,
      :visibility,
      power_curve: [[]] # to squelch unpermitted param warning
    ).merge(power_curve_params)
  end

  def power_curve_params
    # Workaround to permit array of arrays
    ActionController::Parameters.new(
      power_curve: request.parameters[:power_curve]
    ).compact.permit!
  end
end

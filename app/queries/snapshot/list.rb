class Snapshot::List < ApplicationQuery
  param :t, Integer, range: (-1..)
  context :current_user, User, required: true
  context :for_activity, Activity, required: true

  def resolve(params, context)
    current_user = context[:current_user]
    for_activity = context[:for_activity]

    # Check user has access to view the activity
    if Activity::List.exec(nil, {current_user: current_user}).where(id: for_activity.id).blank?
      raise ForbiddenError.no_permission("view this activity")
    end

    for_activity.snapshots.where("t > ?", params[:t])
  end
end

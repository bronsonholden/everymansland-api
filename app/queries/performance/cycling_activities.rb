class Performance::CyclingActivities < ApplicationQuery
  param :group, String, in: %w[week month year]
  context :current_user, User, required: true

  def resolve(params, context)
    current_user = context[:current_user]

    scope = current_user.activities.cycling
    scope = scope.group_by_period(params[:group], :started_at) if params[:group].present?
    scope
  end
end

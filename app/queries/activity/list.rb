class Activity::List < ApplicationQuery
  param :sort, String, in: %w[created_at started_at], default: "created_at"
  param :direction, String, in: %w[asc desc], default: "asc"
  param :sport, String, in: Activity::SUPPORTED_SPORT_TYPES.map(&:to_s)
  context :current_user, User
  context :for_user, User

  def resolve(params, context)
    current_user = context[:current_user]
    for_user = context[:for_user]

    scope = if current_user.present?
      # Users can see friends' activities that are not hidden
      Activity
        .not_hidden
        .where(user: current_user.friends)
        .or(Activity.published)
        # Users can always see all of their activities
        .or(Activity.where(user: current_user))
    else
      # Guests can only see published activities
      Activity.published
    end

    scope = scope.where({
      user: for_user,
      sport: params[:sport]
    }.compact)
    scope = scope.order(:"#{params[:sort]}" => params[:direction])
  end
end

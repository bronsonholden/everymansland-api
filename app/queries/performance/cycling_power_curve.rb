# Get activities with a best critical power, grouped by time period
class Performance::CyclingPowerCurve < ApplicationQuery
  param :group, String, in: %w[week month year], default: "week"
  context :current_user, User, required: true

  def resolve(params, context)
    current_user = context[:current_user]

    scope = current_user.activities.cycling

    # Generate a clause for grouping by date, courtesy of groupdate
    epoch_clause = scope
      .group_by_period(params[:group], :started_at)
      .group_values
      .first
      .gsub("activities", "inner_activities")

    # Self-join unnested table and use power comparison to select rows with
    # the maximum power for each epoch & duration
    scope = scope.joins(
      <<-SQL
        left join (
          select id, #{epoch_clause} as epoch, duration, power
          from
            activities as inner_activities,
            unnest(
              inner_activities.power_curve[:][1:1],
              inner_activities.power_curve[:][2:2]
            ) as x(duration, power)
        ) as reading on reading.id = activities.id

        left join (
          select id, #{epoch_clause} as epoch, duration, power
          from
            activities as inner_activities,
            unnest(
              inner_activities.power_curve[:][1:1],
              inner_activities.power_curve[:][2:2]
            ) as x(duration, power)
        ) as compare
        on
          reading.epoch = compare.epoch
          and reading.duration = compare.duration
          and reading.power < compare.power
      SQL
    ).where("compare.power is null")

    scope
      .reselect("activities.*, reading.*")
      .order("reading.epoch asc, reading.duration asc")
  end
end

class Activity < ApplicationRecord
  include FitConstants

  SUPPORTED_SPORT_TYPES = %i[
    cycling
    running
    walking
    fishing
  ].freeze

  validates :sport, presence: true
  validates :started_at, presence: true
  validate :critical_power_shape

  belongs_to :condition, optional: true
  has_many :snapshots, dependent: :delete_all

  # Self-joins to unnest the critical power array. Duration and power are
  # aliased as `peak.duration` and `peak.power` respectively, allowing
  #  aggregates e.g. `group("peak.duration").maximum("peak.power")` for best
  # critical power.
  scope :unnest_critical_power, -> {
    select("activities.*")
    .joins(
      <<-SQL
        left join (
          select id, duration, power
          from
          activities as inner_activities,
            unnest(
              inner_activities.critical_power[:][1:1],
              inner_activities.critical_power[:][2:2]
            ) as x(duration, power)
        ) as peak on peak.id = activities.id
      SQL
    )
  }

  private

  def critical_power_shape
    unless critical_power.is_a?(Array) && critical_power.all? { |p| p.is_a?(Array) && p.all? { |v| v.is_a?(Integer) } }
      errors.add(:critical_power, "must be an array of duration and power arrays")
    end
  end
end

class Activity < ApplicationRecord
  include FitUploader::Attachment(:fit)
  include FitConstants::Sport[]

  SUPPORTED_SPORT_TYPES = %i[
    cycling
    running
    walking
    fishing
  ].freeze

  enum visibility: %i[hidden shared published]
  enum state: %i[pending processed]

  validate :power_curve_shape

  belongs_to :condition, optional: true
  has_many :snapshots, dependent: :delete_all
  belongs_to :user

  # Self-joins to unnest the power curve array. Reading duration and power are
  # aliased as `reading.duration` and `reading.power` respectively, allowing
  # aggregates e.g. `group("reading.duration").maximum("reading.power")`
  # for best critical power.
  scope :unnest_power_curve, -> {
    joins(
      <<-SQL
        left join (
          select id, duration, power
          from
            activities as inner_activities,
            unnest(
              inner_activities.power_curve[:][1:1],
              inner_activities.power_curve[:][2:2]
            ) as x(duration, power)
        ) as reading on reading.id = activities.id
      SQL
    ).reselect("activities.*", "reading.power", "reading.duration")
  }

  private

  def power_curve_shape
    unless power_curve.nil? || power_curve.is_a?(Array) && power_curve.all? { |p| p.is_a?(Array) && p.all? { |v| v.is_a?(Integer) } }
      errors.add(:power_curve, "must be an array of duration and power arrays")
    end
  end
end

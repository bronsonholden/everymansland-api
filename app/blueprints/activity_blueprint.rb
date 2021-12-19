class ActivityBlueprint < ApplicationBlueprint
  identifier :id

  association :condition, blueprint: ConditionBlueprint, view: :anonymous

  field :critical_power
  field :started_at
  field :snapshots_url do |activity|
    url "activities/#{activity.id}/snapshots"
  end
  field :sport
end

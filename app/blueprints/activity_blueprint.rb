class ActivityBlueprint < ApplicationBlueprint
  identifier :id

  association :condition, blueprint: ConditionBlueprint, view: :anonymous

  field :started_at
  field :snapshots_url do |activity|
    url "activities/#{activity.id}/snapshots"
  end
  field :power_curve
  field :sport

  view :pending do
    exclude :condition
    exclude :power_curve
    exclude :snapshots_url
    exclude :sport
    exclude :started_at
  end
end

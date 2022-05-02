class ActivityBlueprint < ApplicationBlueprint
  identifier :id

  association :condition, blueprint: ConditionBlueprint, view: :anonymous

  field :started_at
  field :snapshots_url do |activity|
    url "activities/#{activity.id}/snapshots"
  end
  field :power_curve
  field :sport

  view :power_curve do
    exclude :id
    exclude :power_curve
    exclude :condition
    exclude :sport
    exclude :snapshots_url
    field :activity_id do |activity|
      activity.id
    end
    field :activity_url do |activity|
      url "activities/#{activity.id}"
    end
    field :duration
    field :power
  end
end

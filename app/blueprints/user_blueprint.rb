class UserBlueprint < ApplicationBlueprint
  identifier :id

  association :condition, blueprint: ConditionBlueprint, view: :anonymous

  field :activities_url do |user|
    url "users/#{user.id}/activities"
  end
  field :first_name
  field :last_name

  view :friend do
    exclude :condition
  end
end

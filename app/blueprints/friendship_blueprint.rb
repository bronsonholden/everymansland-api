class FriendshipBlueprint < ApplicationBlueprint
  identifier :id
  association :user, blueprint: UserBlueprint, view: :friend
  field :respond_url do |friendship|
    url "users/#{friendship.user_id}/friend"
  end
end

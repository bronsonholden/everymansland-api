FactoryBot.define do
  factory :activity do
    association :user, factory: :user
    sport { :cycling }
    started_at { Time.now }
  end
end

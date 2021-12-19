FactoryBot.define do
  factory :activity do
    sport { :cycling }
    started_at { Time.now }
  end
end

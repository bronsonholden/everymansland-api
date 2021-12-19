FactoryBot.define do
  factory :snapshot do
    association :activity, factory: :activity
    heart_rate { Faker::Number.between(from: 120, to: 190) }
    power { Faker::Number.between(from: 80, to: 250) }
    rider_position { %i[seated standing].sample }
    cadence { Faker::Number.between(from: 60, to: 110) }
    cumulative_distance { Faker::Number.between(from: 20, to: 180) }
    speed { Faker::Number.between(from: 20, to: 40) }
    temperature { Faker::Number.between(from: 5, to: 35) }
    raw_data { Hash.new }
    location { "POINT(-96.729674 32.815745)" }
    altitude { Faker::Number.between(from: 30, to: 100) }
    timestamp { Time.now }
  end
end

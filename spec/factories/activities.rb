FactoryBot.define do
  factory :activity do
    association :user, factory: :user
    sport { :cycling }
    started_at { Time.now }
    power_curve { [] }
    distance { 25 }
    elevation_gain { 200 }
    elevation_loss { 200 }
    calories_burned { 500 }
    average_speed { 25 }
    max_speed { 40 }
    average_power { 175 }
    max_power { 230 }
    average_heart_rate { 160 }
    max_heart_rate { 170 }
    average_cadence { 90 }
    max_cadence { 100 }
    elapsed_time { 65.minutes }
    moving_time { 1.hour }
    cycling_normalized_power { 180 }
    cycling_training_stress_score { 50 }
    cycling_intensity_factor { 0.78 }
  end
end

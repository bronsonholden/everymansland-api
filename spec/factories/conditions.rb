FactoryBot.define do
  factory :condition do
    weight { Faker::Number.between(from: 50, to: 85) }
    cycling_ftp { weight * Faker::Number.between(from: 1.8, to: 5.3) }
  end
end

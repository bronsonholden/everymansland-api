FactoryBot.define do
  factory :user do
    association :condition, factory: :condition
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    height { Faker::Number.between(from: 140, to: 200) }
    password { Faker::Internet.password }
    password_confirmation { password }
    sex { User.sexes.keys.sample }
    avatar { Rack::Test::UploadedFile.new("spec/fixtures/avatar512.jpeg") }
  end
end

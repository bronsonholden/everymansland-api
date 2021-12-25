FactoryBot.define do
  factory :user do
    association :condition, factory: :condition
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    password_confirmation { password }
    avatar { Rack::Test::UploadedFile.new("spec/fixtures/avatar512.jpeg") }
  end
end

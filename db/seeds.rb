User.create!(
  first_name: "Paul",
  last_name: "Holden",
  sex: "male",
  height: 171,
  email: "paul@paulholden.dev",
  password: "password",
  password_confirmation: "password",
  condition: Condition.new(weight: 70, cycling_ftp: 204)
)

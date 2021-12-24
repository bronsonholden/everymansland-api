source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.3"

gem "rails", "~> 6.1.4", ">= 6.1.4.1"

gem "activerecord-postgis-adapter"
gem "bcrypt", "~> 3.1.7"
gem "bootsnap", ">= 1.4.4", require: false
gem "blueprinter", "~> 0.25.3"
gem "delayed_job_active_record"
gem "fastimage"
gem "groupdate"
gem "jwt"
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"
gem "rack-cors"
gem "rails_param"
gem "rgeo-geojson"
gem "rubyfit", git: "https://github.com/everymansland/rubyfit.git", branch: "develop"
gem "shrine", "~> 3.0"

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "database_cleaner-active_record"
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-rails"
end

group :development do
  gem "dotenv"
  gem "letter_opener"
  gem "listen", "~> 3.3"
  gem "standardrb"
end

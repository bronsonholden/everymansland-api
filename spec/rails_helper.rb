require "spec_helper"

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
abort("Rails is running in production mode!") if Rails.env.production?

require "rspec/rails"
require "database_cleaner/active_record"

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # Gems may also be filtered via
  # config.filter_gems_from_backtrace("gem name")

  config.before(:suite) do
    # Exclude spatial_ref_sys table (used by PostGIS)
    DatabaseCleaner.clean_with(:truncation, except: %w[spatial_ref_sys])
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    Shrine.storages[:cache].clear!
    Shrine.storages[:store].clear!
  end
end

require "shrine"
require "shrine/storage/file_system"

if Rails.env.production?
  s3_options = {
    access_key_id: Rails.application.secrets.aws_s3_access_key_id,
    secret_access_key: Rails.application.secrets.aws_s3_secret_access_key,
    bucket: Rails.application.secrets.aws_s3_bucket_name,
    region: "us-east-1"
  }
  Shrine.storages = {
    cache: Shrine::Storage::S3.new(prefix: "cache", **s3_options),
    store: Shrine::Storage::S3.new(prefix: "store", **s3_options)
  }
else
  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new("storage", prefix: "#{Rails.env}/uploads/cache"),
    store: Shrine::Storage::FileSystem.new("storage", prefix: "#{Rails.env}/uploads/store")
  }
end

Shrine.plugin :activerecord
Shrine.plugin :validation_helpers
Shrine.plugin :determine_mime_type

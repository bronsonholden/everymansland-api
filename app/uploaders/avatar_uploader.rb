class AvatarUploader < Shrine
  plugin :store_dimensions

  Attacher.validate do
    validate_max_size 5 * 1024 * 1024
    validate_mime_type_inclusion %w[image/jpeg image/png image/gif]
    validate_min_width 128
    validate_min_height 128
    validate_max_width 1024
    validate_max_height 1024
  end
end

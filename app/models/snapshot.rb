class Snapshot < ApplicationRecord
  enum rider_position: %i[seated standing], _suffix: true

  belongs_to :activity
end

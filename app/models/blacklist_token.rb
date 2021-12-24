class BlacklistToken < ApplicationRecord
  validates :jti, presence: true
  validates :exp, presence: true
end

class RefreshToken < ApplicationRecord
  belongs_to :user
  before_create :set_expires_at
  validates :token, presence: true, uniqueness: true

  private

  def set_expires_at
    self.expires_at ||= 2.weeks.from_now
  end
end

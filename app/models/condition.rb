# The variable physical condition of a person
class Condition < ApplicationRecord
  validates :weight, presence: true, numericality: {greater_than: 0}
  validates :cycling_ftp, numericality: {greater_than: 0}, allow_nil: true

  def cycling_wkg
    cycling_ftp / weight unless cycling_ftp.nil?
  end
end

class RenameActivityCriticalPowerToPowerCurve < ActiveRecord::Migration[6.1]
  def change
    add_column :activities, :power_curve, :integer, array: true

    Activity.in_batches.each_record do |activity|
      activity.update(power_curve: activity.critical_power)
    end

    remove_column :activities, :critical_power
  end
end

class AddActivitySummaryMetrics < ActiveRecord::Migration[6.1]
  def change
    add_column :activities, :distance, :float
    add_column :activities, :elevation_gain, :integer
    add_column :activities, :elevation_loss, :integer
    add_column :activities, :calories_burned, :integer
    add_column :activities, :average_speed, :float
    add_column :activities, :max_speed, :float
    add_column :activities, :average_power, :integer
    add_column :activities, :max_power, :integer
    add_column :activities, :average_heart_rate, :integer
    add_column :activities, :max_heart_rate, :integer
    add_column :activities, :average_cadence, :integer
    add_column :activities, :max_cadence, :integer
    add_column :activities, :elapsed_time, :integer
    add_column :activities, :moving_time, :integer
    add_column :activities, :cycling_normalized_power, :integer
    add_column :activities, :cycling_training_stress_score, :float
    add_column :activities, :cycling_intensity_factor, :float
  end
end

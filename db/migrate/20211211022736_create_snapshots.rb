class CreateSnapshots < ActiveRecord::Migration[6.1]
  def change
    create_table :snapshots do |t|
      t.references :activity, foreign_key: true, null: false
      t.integer :heart_rate
      t.integer :power
      t.integer :rider_position
      t.integer :cadence
      t.integer :t, null: false
      t.float :cumulative_distance
      t.float :speed
      t.integer :temperature
      t.json :raw_data, null: false
      t.st_point :location, geographic: true
      t.float :altitude
      t.datetime :timestamp, null: false
      t.timestamps
    end
  end
end

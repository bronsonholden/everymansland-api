class CreateActivities < ActiveRecord::Migration[6.1]
  def change
    create_table :activities do |t|
      t.references :condition, foreign_key: true
      t.datetime :started_at, null: false
      t.integer :sport, null: false
      t.integer :critical_power, array: true
      t.timestamps
    end
  end
end

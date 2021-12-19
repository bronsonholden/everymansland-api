class CreateConditions < ActiveRecord::Migration[6.1]
  def change
    create_table :conditions do |t|
      t.float :weight, null: false
      t.integer :cycling_ftp
      t.timestamps
    end
  end
end

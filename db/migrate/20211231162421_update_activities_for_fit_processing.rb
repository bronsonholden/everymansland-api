class UpdateActivitiesForFitProcessing < ActiveRecord::Migration[6.1]
  def change
    add_column :activities, :fit_data, :text
    add_column :activities, :state, :integer

    Activity.update_all(state: Activity.states[:processed])

    change_column_default :activities, :state, Activity.states[:pending]
    change_column_null :activities, :sport, true
    change_column_null :activities, :started_at, true
  end
end

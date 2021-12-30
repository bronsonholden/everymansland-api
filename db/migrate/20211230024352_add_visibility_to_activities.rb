class AddVisibilityToActivities < ActiveRecord::Migration[6.1]
  def change
    add_column :activities, :visibility, :integer

    Activity.update_all(visibility: Activity.visibilities[:network])

    change_column_default :activities, :visibility, Activity.visibilities[:network]
    change_column_null :activities, :visibility, false
  end
end

class AddUserActivitiesAssociation < ActiveRecord::Migration[6.1]
  def change
    add_reference :activities, :user, foreign_key: true
    Activity.update_all(user_id: User.first.id)
    change_column_null :activities, :user_id, false
  end
end

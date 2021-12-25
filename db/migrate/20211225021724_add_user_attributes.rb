class AddUserAttributes < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    add_column :users, :sex, :integer
    add_column :users, :height, :integer
    # We all start out as females, right?
    User.update_all(sex: User.sexes[:female], height: 1)
    change_column_null :users, :sex, false
    change_column_null :users, :height, false
  end

  def down
    remove_column :users, :sex
    remove_column :users, :height
  end
end

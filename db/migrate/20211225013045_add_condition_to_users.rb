class AddConditionToUsers < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :condition, foreign_key: true

    User.in_batches do |users|
      users.each do |user|
        user.create_condition!(weight: 1)
      end
    end

    change_column_null :users, :condition_id, false
  end
end

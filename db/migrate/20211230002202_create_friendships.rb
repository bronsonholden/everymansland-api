class CreateFriendships < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    create_table :friendships do |t|
      t.references :user, foreign_key: true
      t.references :friend, foreign_key: {to_table: :users}
      t.timestamps
    end

    add_index :friendships, [:user_id, :friend_id], unique: true
    add_index :friendships, [:friend_id, :user_id], unique: true
  end
end

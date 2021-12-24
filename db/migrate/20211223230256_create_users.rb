class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false, index: {unique: true}
      t.string :password_digest
      t.string :confirmation_token, index: {unique: true}
      t.text :avatar_data
      t.timestamps
    end
  end
end

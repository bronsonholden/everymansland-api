class CreateBlacklistTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :blacklist_tokens do |t|
      t.string :jti, null: false, index: true
      t.datetime :exp, null: false
    end
  end
end

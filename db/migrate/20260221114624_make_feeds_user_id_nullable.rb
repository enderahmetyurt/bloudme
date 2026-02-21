class MakeFeedsUserIdNullable < ActiveRecord::Migration[8.2]
  def change
    remove_foreign_key :feeds, :users
    change_column_null :feeds, :user_id, true
  end
end

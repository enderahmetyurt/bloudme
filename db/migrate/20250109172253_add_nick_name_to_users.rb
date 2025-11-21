class AddNickNameToUsers < ActiveRecord::Migration[8.1]
  def change
    add_index :users, :nickname, unique: true
  end
end

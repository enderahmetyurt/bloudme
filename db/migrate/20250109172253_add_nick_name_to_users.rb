class AddNickNameToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :nick_name, :string
  end
end

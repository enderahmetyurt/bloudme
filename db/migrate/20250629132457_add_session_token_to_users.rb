class AddSessionTokenToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :session_token, :string
  end
end

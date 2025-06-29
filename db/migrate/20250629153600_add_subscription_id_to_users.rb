class AddSubscriptionIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :subscription_id, :string
  end
end

class AddSubscriptionToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :subscription_active, :boolean, default: false
    add_column :users, :subscription_expires_at, :datetime
  end
end

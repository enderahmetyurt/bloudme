class CreateFeedSubscriptions < ActiveRecord::Migration[8.2]
  def change
    create_table :feed_subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :feed, null: false, foreign_key: true

      t.timestamps
    end

    add_index :feed_subscriptions, [:user_id, :feed_id], unique: true
  end
end

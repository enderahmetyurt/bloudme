class AddIndexOnFeedsFeedUrl < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_index :feeds, :feed_url, algorithm: :concurrently, if_not_exists: true
  end
end

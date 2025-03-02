class ChangeNameUrlToFeedUrl < ActiveRecord::Migration[8.1]
  def self.up
    rename_column :feeds, :url, :feed_url
  end
end

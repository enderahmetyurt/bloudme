class AddNewFieldsToFeeds < ActiveRecord::Migration[8.1]
  def change
    add_column :feeds, :favicon, :string
    add_column :feeds, :is_podcast, :boolean
    add_column :feeds, :site_url, :string
  end
end

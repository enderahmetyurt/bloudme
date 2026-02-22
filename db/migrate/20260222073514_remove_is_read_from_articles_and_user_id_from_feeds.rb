class RemoveIsReadFromArticlesAndUserIdFromFeeds < ActiveRecord::Migration[8.2]
  def change
    remove_column :articles, :is_read, :boolean
    remove_column :feeds, :user_id, :integer
  end
end

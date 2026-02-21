class AddUniqueIndexToArticlesFeedIdAndLink < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_index :articles, [:feed_id, :link], unique: true, algorithm: :concurrently, if_not_exists: true
  end
end

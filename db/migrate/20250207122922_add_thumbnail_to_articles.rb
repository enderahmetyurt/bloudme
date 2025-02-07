class AddThumbnailToArticles < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :thumbnail, :string
  end
end

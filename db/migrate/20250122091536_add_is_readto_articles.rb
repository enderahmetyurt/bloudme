class AddIsReadtoArticles < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :is_read, :boolean, default: false
  end
end

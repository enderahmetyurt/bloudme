class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.references :feed, null: false, foreign_key: true
      t.string :title
      t.text :content
      t.datetime :published_at
      t.string :link

      t.timestamps
    end
  end
end

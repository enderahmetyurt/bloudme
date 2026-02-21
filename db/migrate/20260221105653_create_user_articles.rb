class CreateUserArticles < ActiveRecord::Migration[8.2]
  def change
    create_table :user_articles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :article, null: false, foreign_key: true
      t.boolean :is_read, default: false, null: false

      t.timestamps
    end

    add_index :user_articles, [:user_id, :article_id], unique: true
  end
end

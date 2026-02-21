class FixUserArticlesConstraints < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    # Remove duplicate user_articles rows, keeping the one with is_read: true if any
    execute <<~SQL
      DELETE FROM user_articles
      WHERE id NOT IN (
        SELECT DISTINCT ON (user_id, article_id) id
        FROM user_articles
        ORDER BY user_id, article_id, is_read DESC, id ASC
      )
    SQL

    # Fix is_read nulls before adding not null constraint
    execute "UPDATE user_articles SET is_read = false WHERE is_read IS NULL"

    change_column_null :user_articles, :is_read, false
    change_column_default :user_articles, :is_read, false

    add_index :user_articles, [:user_id, :article_id], unique: true,
              algorithm: :concurrently,
              name: "index_user_articles_on_user_id_and_article_id"
  end

  def down
    remove_index :user_articles, name: "index_user_articles_on_user_id_and_article_id"
    change_column_null :user_articles, :is_read, true
    change_column_default :user_articles, :is_read, nil
  end
end

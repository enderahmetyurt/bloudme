class AddSocialLinksToUsers < ActiveRecord::Migration[8.2]
  def change
    add_column :users, :twitter, :string, default: "", null: true
    add_column :users, :bsky, :string, default: "", null: true
    add_column :users, :github, :string, default: "", null: true
    add_column :users, :linkedin, :string, default: "", null: true
    add_column :users, :mastodon, :string, default: "", null: true
    add_column :users, :website, :string, default: "", null: true
    add_column :users, :bio, :text, default: "", null: true
  end
end

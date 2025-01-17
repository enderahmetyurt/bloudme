class CreateFeeds < ActiveRecord::Migration[8.1]
  def change
    create_table :feeds do |t|
      t.references :user, null: false, foreign_key: true
      t.string :url
      t.string :title
      t.string :description

      t.timestamps
    end
  end
end

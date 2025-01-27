class RemovePost < ActiveRecord::Migration[8.1]
  def up
    drop_table :posts
  end
end

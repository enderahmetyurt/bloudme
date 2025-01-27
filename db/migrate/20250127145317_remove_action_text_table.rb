class RemoveActionTextTable < ActiveRecord::Migration[8.1]
  def up
    drop_table :action_text_rich_texts
  end
end

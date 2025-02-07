class AddYoutubeInfoToArticles < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :youtube_channel_id, :string
    add_column :articles, :youtube_video_id, :string
  end
end

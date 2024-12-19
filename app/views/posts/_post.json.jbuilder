json.extract! post, :id, :title, :content, :user_id, :published, :created_at, :updated_at
json.url post_url(post, format: :json)

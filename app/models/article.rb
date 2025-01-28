class Article < ApplicationRecord
  belongs_to :feed
  scope :recent, -> { order(published_at: :desc) }
  scope :unread, -> { where(is_read: false) }
end

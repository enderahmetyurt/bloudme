class Article < ApplicationRecord
  belongs_to :feed
  scope :recent, -> { order(published_at: :desc) }
  scope :unread, -> { where(is_read: false) }

  scope :by_current_user, ->(user) {
    joins(feed: :user).where(feeds: { user: user })
  }
end

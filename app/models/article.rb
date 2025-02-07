class Article < ApplicationRecord
  belongs_to :feed
  scope :recent, -> { order(published_at: :desc) }
  scope :unread, -> { where(is_read: false) }
  scope :read, -> { where(is_read: true) }

  scope :by_current_user, ->(user) {
    joins(feed: :user).where(feeds: { user: user })
  }

  def youtube?
    self.thumbnail.present?
  end
end

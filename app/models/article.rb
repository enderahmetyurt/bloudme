class Article < ApplicationRecord
  belongs_to :feed
  has_many :bookmarks, dependent: :destroy
  has_many :users_who_bookmarked, through: :bookmarks, source: :user

  scope :recent, -> { order(published_at: :desc) }
  scope :unread, -> { where(is_read: false) }
  scope :read, -> { where(is_read: true) }

  scope :by_current_user, ->(user) {
    joins(feed: :user).where(feeds: { user: user })
  }

  scope :search, ->(query) {
    return all if query.blank?

    where("articles.title LIKE :query OR articles.content LIKE :query", query: "%#{query}%")
  }

  def youtube?
    self.thumbnail.present?
  end

  def bookmarked_for_user?(user)
    bookmarks.exists?(user: user)
  end
end

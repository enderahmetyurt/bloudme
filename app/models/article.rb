class Article < ApplicationRecord
  belongs_to :feed
  has_many :bookmarks, dependent: :destroy
  has_many :users_who_bookmarked, through: :bookmarks, source: :user
  has_many :user_articles, dependent: :destroy

  scope :recent, -> { order(published_at: :desc) }

  scope :for_user, ->(user) {
    joins(:user_articles).where(user_articles: { user_id: user.id })
  }

  scope :unread_for_user, ->(user) {
    for_user(user).where(user_articles: { is_read: false })
  }

  scope :read_for_user, ->(user) {
    for_user(user).where(user_articles: { is_read: true })
  }

  def read_for_user?(user)
    user_articles.exists?(user_id: user.id, is_read: true)
  end

  scope :search, ->(query) {
    return all if query.blank?

    where("LOWER(articles.title) LIKE LOWER(:query) OR LOWER(articles.content) LIKE LOWER(:query)", query: "%#{query}%")
  }

  def youtube?
    self.thumbnail.present?
  end

  def bookmarked_for_user?(user)
    bookmarks.exists?(user: user)
  end
end

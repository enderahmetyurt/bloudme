class Feed < ApplicationRecord
  has_many :articles, dependent: :destroy
  has_many :feed_subscriptions, dependent: :destroy
  has_many :subscribers, through: :feed_subscriptions, source: :user

  validates :feed_url, presence: true, uniqueness: true

  scope :recent, -> { order(created_at: :desc) }
end

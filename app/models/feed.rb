class Feed < ApplicationRecord
  belongs_to :user
  has_many :articles, dependent: :destroy
  has_many :feed_subscriptions, dependent: :destroy
  has_many :subscribers, through: :feed_subscriptions, source: :user

  validates :feed_url, presence: true, uniqueness: { scope: :user_id }

  scope :recent, -> { order(created_at: :desc) }
end

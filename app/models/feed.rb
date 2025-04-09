class Feed < ApplicationRecord
  belongs_to :user
  has_many :articles, dependent: :destroy

  validates :feed_url, presence: true, uniqueness: { scope: :user_id }

  scope :recent, -> { order(created_at: :desc) }
end

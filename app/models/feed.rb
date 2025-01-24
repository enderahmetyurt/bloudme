class Feed < ApplicationRecord
  belongs_to :user
  has_many :articles, dependent: :destroy

  validates :url, presence: true

  scope :recent, -> { order(created_at: :desc) }
end

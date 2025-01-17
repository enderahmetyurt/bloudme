class Article < ApplicationRecord
  belongs_to :feed
  scope :recent, -> { order(published_at: :desc) }
end

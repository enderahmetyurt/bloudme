class Post < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 100 }
  validates :content, presence: true, length: { maximum: 400 }

  scope :published, -> { where(published: true) }
  scope :recent, -> { order(created_at: :desc) }
end

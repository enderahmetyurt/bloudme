class Post < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  scope :published, -> { where(published: true) }
  scope :recent, -> { order(created_at: :desc) }

  has_rich_text :content
end

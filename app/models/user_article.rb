class UserArticle < ApplicationRecord
  belongs_to :user
  belongs_to :article

  validates :article_id, uniqueness: { scope: :user_id }

  scope :unread, -> { where(is_read: false) }
  scope :read, -> { where(is_read: true) }
end

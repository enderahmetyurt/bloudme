class User < ApplicationRecord
  DICE_BEAR_URL = "https://api.dicebear.com/6.x/adventurer/svg?".freeze

  before_create :set_nick_name
  before_create :set_random_avatar

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :feeds, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, uniqueness: true, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  private

  def set_random_avatar
    self.avatar_url ||= "#{DICE_BEAR_URL}seed=#{SecureRandom.hex(8)}"
  end

  def set_nick_name
    self.nick_name ||= email_address.split("@").first
  end
end

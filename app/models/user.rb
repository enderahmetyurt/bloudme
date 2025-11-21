class User < ApplicationRecord
  DICE_BEAR_URL = "https://api.dicebear.com/6.x/adventurer/svg?".freeze
  AVAILABLE_LOCALES = [
    [ "English", "en" ],
    [ "Turkish", "tr" ]
  ].freeze

  before_create :set_nick_name
  before_create :set_random_avatar
  before_create :generate_confirmation_token
  before_create :generate_session_token
  before_create :set_trial_end_date

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :feeds, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_articles, through: :bookmarks, source: :article

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, uniqueness: true, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }
  validates :nick_name, uniqueness: true

  class << self
    def localized_locales
      AVAILABLE_LOCALES.map do |name, code|
        [ I18n.t("languages.#{code}"), code ]
      end
    end
  end

  def to_param
    nick_name
  end

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64
    self.confirmation_sent_at = Time.current
  end

  def confirm_email!
    update(email_confirmed: true, confirmation_token: nil, confirmation_sent_at: nil)
  end

  def confirmation_expired?
    confirmation_sent_at && confirmation_sent_at < 7.days.ago
  end

  def trial_ends?
    return false if trial_end_date.nil?

    DateTime.current > trial_end_date
  end

  private

  def set_random_avatar
    self.avatar_url ||= "#{DICE_BEAR_URL}seed=#{SecureRandom.hex(8)}"
  end

  def set_nick_name
    base_nick_name = email_address.split("@").first
    self.nick_name = base_nick_name

    if User.exists?(nick_name: self.nick_name)
      self.nick_name = Faker::Book.author
    end
  end

  def generate_session_token
    self.session_token ||= SecureRandom.hex(32)
  end

  def set_trial_end_date
    self.trial_end_date = DateTime.current + 7.days
  end
end

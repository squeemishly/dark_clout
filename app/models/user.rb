class User < ApplicationRecord
  has_secure_password validations: false

  with_options if: ->(u){u.fb_id.nil?} do |user|
    user.validate do |record|
      record.errors.add(:password, :blank) unless record.password_digest.present?
    end
    user.validates_length_of :password, maximum: ActiveModel::SecurePassword::MAX_PASSWORD_LENGTH_ALLOWED
    user.validates_confirmation_of :password, allow_blank: true
  end

  validates_format_of :username, with: /\A[a-zA-Z]+([a-zA-Z]|\d)*\Z/, message: 'can only contain letters and numbers'
  validates :username, presence: true
  validates :name, presence: true
  validates :status, presence: true
  validates :email, presence: true
  validates :email, format: {with: /\A([a-z0-9_\.-]+\@[\da-z\.-]+\.[a-z\.]{2,6})\z/, message: "Address Invalid Format"}
  validates :phone, presence: true
  validates :phone, format: { with: /\d{3}[-\s]?\d{3}[-\s]?\d{4}/, message: "Number Invalid Format" }
  validates_uniqueness_of :username, case_sensitive: false

  enum status: %w(active inactive)

  has_many :shared_folders
  has_many :folders_shared_with, through: :shared_folders, source: :folder
  has_many :owned_folders, class_name: "Folder", foreign_key: "user_id"

  after_create :make_home

  def home
    owned_folders.find_by(route: 'home')
  end

  def self.from_omniauth(auth)
    new do |user|
      user.fb_id = auth["uid"]
      user.name = auth["info"]["name"]
      user.email = auth["info"]["email"]
      user.avatar_url = auth["info"]["image"]
      user.token = auth["credentials"]["token"]
    end
  end

private

  def make_home
    owned_folders.new(name: 'home', route: 'home', slug: 'home').save(validate: false)
  end
end

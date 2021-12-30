class User < ApplicationRecord
  include AvatarUploader::Attachment(:avatar)
  include FitConstants::Gender[:sex]

  before_create :set_confirmation_token, unless: :confirmation_token?
  after_create :send_invite

  has_many :activities, dependent: :destroy
  has_many :refresh_tokens, dependent: :destroy
  belongs_to :condition
  accepts_nested_attributes_for :condition
  has_many :friendships, -> { accepted }
  has_many :friends, through: :friendships
  has_many :sent_friend_requests, -> { pending }, class_name: "Friendship"
  has_many :received_friend_requests, -> { pending }, class_name: "Friendship", foreign_key: :friend_id

  has_secure_password validations: false
  validates_confirmation_of :password, if: :password_digest_changed?
  validates_presence_of :password_confirmation, if: :will_save_change_to_password_digest?
  validates :email, presence: true, uniqueness: true

  def confirmation_url
    return unless confirmation_token?
    # TODO
    "http://localhost:8080/confirm/#{confirmation_token}"
  end

  def confirm
    self.confirmation_token = nil
    save
  end

  def send_invite
    UserMailer.invite(self).deliver_now
  end
  handle_asynchronously :send_invite, queue: "user_invites"

  private

  def set_confirmation_token
    self.confirmation_token = SecureRandom.hex(16)
  end
end

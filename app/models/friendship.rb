# Everybody needs friends
class Friendship < ApplicationRecord
  validate :friendship_uniqueness

  belongs_to :user
  belongs_to :friend, class_name: "User"

  scope :pending, -> { reciprocated(false) }
  scope :accepted, -> { reciprocated(true) }

  scope :between, ->(user, friend) {
    where(
      user: user,
      friend: friend
    ).or(Friendship.where(user: friend, friend: user))
  }

  scope :reciprocated, ->(reciprocated) {
    where(
      <<-SQL
        #{reciprocated ? "" : "not"} exists (
          select 1 as one
          from friendships as reciprocal_friendships
          where
            reciprocal_friendships.user_id = friendships.friend_id
            and reciprocal_friendships.friend_id = friendships.user_id
        )
      SQL
    )
  }

  def accepted?
    reciprocal.one?
  end

  def accept
    reciprocal.first_or_create
  end

  def accept!
    begin
      reciprocal.first_or_create!
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end

  def reciprocal
    Friendship.where(friend: user, user: friend)
  end

  def breakup
    Friendship.transaction do
      self.destroy if persisted?
      reciprocal.destroy_all
    end
  end

  def self.makeup!(user, friend)
    Friendship.transaction do
      friendship = Friendship.create!(user: user, friend: friend)
      friendship.accept!
    end
  end

  private

  def friendship_uniqueness
    existing = Friendship.where(user: user, friend: friend).first
    return if existing.blank?
    if existing.accepted?
      errors.add(:base, "You are already friends with this user")
    else
      errors.add(:base, "You have already sent this user a friend request")
    end
  end
end

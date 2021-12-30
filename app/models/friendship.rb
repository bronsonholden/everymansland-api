# Everybody needs friends
class Friendship < ApplicationRecord
  validates :user, presence: true, uniqueness: {scope: :friend_id}
  validates :friend, presence: true, uniqueness: {scope: :user_id}

  belongs_to :user
  belongs_to :friend, class_name: "User"

  scope :pending, -> {
    reciprocated(false)
  }

  scope :accepted, -> {
    reciprocated(true)
  }

  scope :reciprocated, ->(reciprocated) {
    where(
      <<-SQL
        #{reciprocated ? "" : "not"} exists (
          select *
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
    reciprocal.first_or_create!
  end

  def reciprocal
    Friendship.where(friend: user, user: friend)
  end

  def breakup
    Friendship.transaction do
      self.destroy
      reciprocal.destroy_all
    end
  end

  def self.makeup(user, friend)
    Friendship.transaction do
      friendship = Friendship.create(user: user, friend: friend)
      friendship && !!friendship.accept
    end
  end
end

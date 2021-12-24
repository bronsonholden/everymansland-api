class UserMailer < ApplicationMailer
  attr_reader :user

  def invite(user)
    @user = user

    mail to: @user.email
  end
end

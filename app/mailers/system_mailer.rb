class SystemMailer < ActionMailer::Base
  default from: "Yo! B*tch <hello@yobitch.me>"

  def welcome(user)
    @user = user
    mail(
      to: "#{user.name} <#{user.email}>", 
      subject: 'Welcome to Yo! B*tch'
    )
  end

end

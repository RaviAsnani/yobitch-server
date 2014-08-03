class SystemMailer < ActionMailer::Base
  default from: "Lisa <hello@yobitch.me>"

  def welcome(user)
    @user = user
    mail(
      to: "#{user.name} <#{user.email}>", 
      subject: 'Lisa from the Yo! B*tch app team'
    )
  end

end

json.user do
  json.id @user.id
  json.email @user.email
  json.name @user.name
  json.is_free @user.is_free
  json.is_elevated @user.is_elevated
  json.gcm_token @user.gcm_token
  json.auth_token @user.auth_token
  json.messages @user.all_messages do |message|
    json.id message.id
    if @user.is_elevated 
      json.abuse message.abuse
    else
      json.abuse message.sensored_abuse
    end 
  end
  json.friends @user.friends
end
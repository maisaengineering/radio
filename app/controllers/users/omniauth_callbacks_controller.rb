class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    omniauth = request.env["omniauth.auth"]
    @user = User.find_for_facebook_oauth(omniauth, current_user)


    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])

    if authentication && authentication.user.present?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => omniauth['provider']
      sign_in_and_redirect(:user, authentication.user)
    else
      
    end


  end

end
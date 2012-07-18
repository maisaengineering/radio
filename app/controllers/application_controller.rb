class ApplicationController < ActionController::Base
  protect_from_forgery
	# admin auth

	def authenticate_admin!
 		redirect_to login_path unless current_user && current_user.admin?
	end


	def current_admin_user
	  return nil if user_signed_in? && !current_user.admin?
	  current_user
	end

protected

  def sign_in_and_redirect(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    unless resource.admin?
      cookies[:userid] = current_user.id
      RecentActivity.create(:activity_type=> "Login",:user_id => current_user.id,:activity => "logged in")
      render :json => {:message => 'logged_in', :chat_token => set_chat_token, :redirect => stored_location_for(resource)}
    else
      cookies[:userid] = current_user.id
      RecentActivity.create(:activity_type=> "Login",:user_id => current_user.id,:activity => "admin logged in")
      render :json => {:message => 'admin_logged_in', :chat_token => set_chat_token}
    end
  end


  def after_sign_in_path_for(resource)
    if current_admin_user
      return admin_dashboard_path
    else
      return root_path
    end
  end

  def check_logged_in
    
    @logged_in = user_signed_in?
    if !@logged_in
      redirect_to :action => :not_logged_in
    end
  end

  def set_chat_token
    if user_signed_in?
      chat_token = Devise.friendly_token[0,20]
      cookies[:chat_token] = chat_token
      current_user.update_attributes(:chat_token => chat_token)
      chat_token
    end
  end

end


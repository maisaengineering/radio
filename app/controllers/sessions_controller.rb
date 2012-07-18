class SessionsController < Devise::SessionsController

  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => :failure)
    return sign_in_and_redirect(resource_name, resource)
  end

  def failure
    render :json => {:success => false, :errors => ["Login failed."]}
  end
end

# DRAGON BONE CRUSHER
class RegistrationsController < Devise::RegistrationsController

  def create
    build_resource
    
    if resource.save
      RecentActivity.create(:activity_type=> "Register",:user_id => resource.id)
      set_flash_message :notice, :signed_up
      sign_in_and_redirect(resource_name, resource)
    else
      clean_up_passwords(resource)
      render :json => {:errors => resource.errors.full_messages.join(", "), :message => "register_fail"}.to_json
    end
  end
end
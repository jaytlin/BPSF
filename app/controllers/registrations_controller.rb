# Handles user creation and redirects to user profile after creation
class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    build_resource sign_up_params
    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def update
    super
  end

  def after_sign_up_path_for(resource)
    user = User.find resource.id
    admins = Admin.all + SuperUser.all
    if user.type != "Admin"
      WelcomeEmailJob.new.async.perform(resource)
      admins.each do |admin|
        AdminNewuserJob.new.async.perform(user, admin)
      end
    else
      WelcomeAdminJob.new.async.perform(resource)
      admins.each do |admin|
        if admin.id != resource.id
          AdminNewadminJob.new.async.perform(user, admin)
        end
      end
    end
    user.approved = user.init_approved
    user.save!
    user.create_profile!
    edit_user_path id: @user.id
  end
end

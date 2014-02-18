# Base controller
class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  after_filter :store_location

  rescue_from CanCan::AccessDenied do |exception|
    if !current_user || current_user.approved
      redirect_to root_path, flash: { danger: exception.message }
    else
      redirect_to root_path, flash: { danger: "Your account is pending administrator approval!" }
    end
  end

  def store_location
    if (request.fullpath.include? "grants")
      session[:previous_url] = request.fullpath 
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || default_after_sign_in_path_for(resource)
  end

  def default_after_sign_in_path_for(resource)
    return admin_dashboard_path     if ((resource.is_a? Admin) | (resource.is_a? SuperUser))
    return recipient_dashboard_path if resource.is_a? Recipient
    return root_path                if resource.is_a? User
  end
end

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action :set_session_flash

  def set_session_flash
    if current_user.present?
      flash[:info] = "Signed in as #{current_user.username}" if current_user.present?
    else
      flash[:warning] = 'Not signed in.'
    end
  end
end

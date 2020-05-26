class BaseController < ApplicationController
  before_action :init_common_data
  before_action :require_user

  def init_common_data
    @common_data = {
      currentUser: Representers::User.(current_user),
      loggedIn: current_user.present?,
      paths: Representers::Paths.(),
      token: form_authenticity_token
    }
  end

  def require_user
    redirect_to login_path and return unless current_user.present?
  end
end

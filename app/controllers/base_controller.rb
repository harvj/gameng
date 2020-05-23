class BaseController < ApplicationController
  before_action :init_common_data

  def init_common_data
    @common_data = {
      currentUser: Representers::User.(current_user),
      loggedIn: current_user.present?,
      paths: Representers::Paths.()
    }
  end
end

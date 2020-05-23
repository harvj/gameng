class BaseController < ApplicationController
  def index
    flash[:info] = "Signed in as #{current_user.email}" if current_user.present?
  end
end

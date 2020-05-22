class BaseController < ApplicationController
  def index
    flash[:notice] = "Signed in as #{current_user.email}" if current_user.present?
  end
end

class Admin::ApplicationController < ApplicationController
  include Pundit::Authorization

  before_action :require_login
  layout "admin"

  rescue_from Pundit::NotAuthorizedError, with: :pundit_not_authorized

  private

  def pundit_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: admin_root_path)
  end
end

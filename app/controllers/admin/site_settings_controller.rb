class Admin::SiteSettingsController < Admin::ApplicationController
  def edit
    authorize :site_setting, :edit?
  end

  def update
    authorize :site_setting, :update?
    SiteSetting.set('site_header', params[:site_header].presence)
    SiteSetting.set('site_footer', params[:site_footer].presence)
    redirect_to edit_admin_site_settings_path, notice: "Site settings saved."
  end
end

class Admin::SystemSettingsController < Admin::BaseController

  def index
    @settings = SystemSetting.all_with_defaults
  end

  def update
    SystemSetting::SETTINGS.keys.each do |setting|
      SystemSetting.send("#{setting.to_sym}=", params[setting]) if params[setting].present?
    end
    flash[:success] = "Settings Saved"
    redirect_to admin_system_settings_path
  end

end

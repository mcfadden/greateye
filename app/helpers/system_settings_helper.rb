module SystemSettingsHelper
  def input_for_system_setting(system_setting)
    case system_setting.value_type.to_sym
    when :boolean
      hidden_field_tag(system_setting.name, "0") + check_box_tag(system_setting.name, "1", system_setting.value)
    when :string
      text_field_tag(system_setting.name, system_setting.value)
    when :integer
      number_field_tag(system_setting.name, system_setting.value)
    end
  end
end

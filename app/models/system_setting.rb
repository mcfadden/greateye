class SystemSetting < ActiveRecord::Base

  SETTINGS = {
    find_new_events_enabled: {
      type: :boolean,
      default: true
    },
    read_only_mode: {
      type: :boolean,
      default: false
    },
    columns_in_listing_view: {
      type: :integer,
      default: 3
    },
    columns_in_live_view: {
      type: :integer,
      default: 3
    },
    thumbnail_click_action_inline_preview: {
      type: :boolean,
      default: true
    }
  }

  enum value_type: [:boolean, :string, :integer]

  SETTINGS.keys.each do |key|
    self.define_singleton_method key do
      setting = with_name(key)
      if setting.present?
        setting.value
      else
        default_value_for(key)
      end
    end

    self.define_singleton_method "#{key}=" do |new_value|
      setting = self.find_or_create_by(name: key, value_type: SystemSetting.value_types[SETTINGS[key][:type].to_s])
      setting.value = new_value
      setting.save
    end
  end

  def self.with_name(name)
    self.find_by(name: name.to_s)
  end

  def self.default_value_for(name)
    SETTINGS[name.to_sym][:default]
  end

  def self.value_type_for(name)
    SETTINGS[name.to_sym][:type]
  end

  def self.all_with_defaults
    SystemSetting::SETTINGS.keys.map do |setting|
      self.with_name(setting) || open_struct_for_default(setting)
    end
  end

  def self.open_struct_for_default(setting)
    OpenStruct.new(
      name: setting,
      value: self.default_value_for(setting),
      value_type:  self.value_type_for(setting)
    )
  end

  def value
    case value_type.to_sym
    when :boolean
      bool_value
    when :string
      string_value
    when :integer
      integer_value
    end
  end

  def value=(new_value)
    case value_type.to_sym
    when :boolean
      self.bool_value = new_value
    when :string
      self.string_value = new_value.to_s
    when :integer
      self.integer_value = new_value.to_i
    end
  end
end

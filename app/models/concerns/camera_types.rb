module CameraTypes
  extend ActiveSupport::Concern

  included do
    Camera.makes.each do |make|
      scope make, -> { where(make: make) }
      models_for(make: make).each do |model|
        scope "#{make}_#{model}", -> { where(make: make, model: model) }
      end
    end
  end

  class_methods do
    def makes
      make_and_model_map.keys
    end

    def models_for(make:)
      make_and_model_map[make.to_sym].keys
    end

    def type_for(make:, model:)
      make_and_model_map[make.to_sym][model.to_sym]
    end

    def make_and_model_map
      {
        amcrest: {
          ip3m_956: Camera::Amcrest::Ip3m,
          ip5m_1173: Camera::Amcrest::Ip5m
        },
        foscam: {
          fi8910: Camera::Foscam::Sd,
          fi8918: Camera::Foscam::Sd,
          fi9821: Camera::Foscam::HdCgi
        },
        reolink: {
          rlc410: Camera::Reolink
        }
      }
    end
  end

  def camera_type
    return nil if make.nil? || model.nil?
    "#{make}:::#{model}"
  end

  def camera_type=(value)
    self.make, self.model = value.split(':::')
  end

end

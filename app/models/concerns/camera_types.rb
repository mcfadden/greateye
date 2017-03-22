module CameraTypes
  extend ActiveSupport::Concern

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
          ip3m_956: Camera::Amcrest::Ip3m
        },
        foscam: {
          fi8910: Camera::Foscam::Sd,
          fi8918: Camera::Foscam::Sd,
          fi9821: Camera::Foscam::HdCgi
        },
        reolink: {
          rlc410: Camear::Reolink
        }
      }
    end
  end

end

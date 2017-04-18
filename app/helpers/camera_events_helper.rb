module CameraEventsHelper
  def column_classes_for_index
    classes = []
    case SystemSetting.columns_in_listing_view
    when 1
      classes << 'col-sm-12'
      classes << 'col-md-12'
    when 2
      classes << 'col-sm-12'
      classes << 'col-md-6'
    when 3
      classes << 'col-sm-6'
      classes << 'col-md-4'
    when 4
      classes << 'col-sm-6'
      classes << 'col-md-3'
    when 5..6
      classes << 'col-sm-4'
      classes << 'col-md-2'
    else
      classes << 'col-sm-2'
      classes << 'col-md-1'
    end
    classes
  end
end

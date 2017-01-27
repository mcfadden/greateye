# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if Camera.count == 0
  Camera.create(name: "Driveway", model: 0, active: true)
  Camera.create(name: "Porch", model: 0, active: true)
  Camera.create(name: "Back Yard", model: 0, active: true)
  Camera.create(name: "Front Yard", model: 0, active: true)
end

durations = []
100.times{durations << 35}
25.times{durations << rand(200) + 30}

Camera.all.each do |camera|
  time_offset = Time.now
  100..(rand(500) + 300).times do |i|
    time_offset -= (rand(5000) + 1000).seconds
    event = camera.camera_events.create(status: :complete, duration: durations.sample, event_timestamp: time_offset)

    event.camera_event_assets.create(asset_type: 'image/jpeg', status: :complete)
    event.camera_event_assets.create(asset_type: 'video/mp4', status: :complete)
  end
end

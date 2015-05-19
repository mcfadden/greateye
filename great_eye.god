CURRENT_DIRECTORY = Dir.pwd

# God.watch do |w|
#   w.name = "unicorn"
#   w.dir = "#{CURRENT_DIRECTORY}"
#   w.start = "unicorn_rails --listen 7500"
#   w.log = "#{CURRENT_DIRECTORY}/log/unicorn.log"
#   w.keepalive
# end

God.watch do |w|
  w.name = "sidekiq"
  w.dir = "#{CURRENT_DIRECTORY}"
  w.start = "bundle exec sidekiq -c 1"
  w.log = "#{CURRENT_DIRECTORY}/log/sidekiq.log"

  w.keepalive
end

God.watch do |w|
  w.name = "clockwork"
  w.dir = "#{CURRENT_DIRECTORY}"
  w.start = "bundle exec clockwork clock.rb"
  w.log = "#{CURRENT_DIRECTORY}/log/clockwork.log"

  w.keepalive
end



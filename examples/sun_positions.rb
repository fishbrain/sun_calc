# frozen_string_literal: true

require 'sun_calc'

stockholm = [59.3345, 18.0662]
lat, lng = stockholm
now = Time.now.utc

(0..(24 * 2)).each do |hour|
  date = now + hour * 3600
  altitude = SunCalc.sun_position(date, lat, lng)[:altitude]
  normalized_altitude = (altitude + Math::PI / 2) / Math::PI
  puts "#{date}: " \
       "#{'*' * (normalized_altitude * 100).to_i} (#{altitude})"
end

puts "\n--------- AXIS --------: [-PI/2 #{'-' * 42} 0 #{'-' * 42} PI/2]"

# frozen_string_literal: true

require 'sun_calc'

now = Time.now.utc

1_000_000.times do
  lat = rand * 180 - 90
  lng = rand * 360 - 180
  time = now - rand * 3600 * 24 * 365 * 10
  # puts "SunCalc.sun_times(#{time}, #{lat}, #{lng})"
  SunCalc.sun_times(time, lat, lng)
  # puts "SunCalc.sun_position(#{time}, #{lat}, #{lng})"
  SunCalc.sun_position(time, lat, lng)
  # puts "SunCalc.moon_position(#{time}, #{lat}, #{lng})"
  SunCalc.moon_position(time, lat, lng)
  # puts "SunCalc.moon_times(#{time}, #{lat}, #{lng})"
  SunCalc.moon_position(time, lat, lng)
  # puts "SunCalc.moon_illumination(#{time})"
  SunCalc.moon_illumination(time)
end

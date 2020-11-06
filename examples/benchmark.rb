# frozen_string_literal: true

require 'benchmark'

require 'sun_calc'

now = Time.now.utc

params = Array.new(10_000) do
  lat = rand * 180 - 90
  lng = rand * 360 - 180
  time = now - rand * 3600 * 24 * 365 * 10
  [time, lat, lng]
end

Benchmark.bmbm do |x|
  x.report('sun_position') do
    params.each do |p|
      SunCalc.sun_position(*p)
    end
  end

  x.report('sun_times') do
    params.each do |p|
      SunCalc.sun_times(*p)
    end
  end

  x.report('moon_position') do
    params.each do |p|
      SunCalc.moon_position(*p)
    end
  end

  x.report('moon_times') do
    params.each do |p|
      SunCalc.moon_times(*p)
    end
  end

  x.report('moon_illumination') do
    params.each do |p|
      SunCalc.moon_illumination(p.first)
    end
  end
end

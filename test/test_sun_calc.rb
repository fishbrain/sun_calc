# frozen_string_literal: true

require 'test_helper'
require 'sun_calc'

class SunCalcTest < Minitest::Test
  def setup
    @date = Time.iso8601('2013-03-05T00:00:00Z')
    @lat = 50.5
    @lng = 30.5
  end

  def test_sun_position
    sun_position = SunCalc.sun_position(@date, @lat, @lng)
    assert_in_delta sun_position[:azimuth], -2.5003175907168385, 1E-15
    assert_in_delta sun_position[:altitude], -0.7000406838781611, 1E-15
  end

  def test_sun_times
    expected_events_and_times = {
      solar_noon: '2013-03-05T10:10:57Z',
      nadir: '2013-03-04T22:10:57Z',
      sunrise: '2013-03-05T04:34:56Z',
      sunset: '2013-03-05T15:46:57Z',
      sunrise_end: '2013-03-05T04:38:19Z',
      sunset_start: '2013-03-05T15:43:34Z',
      dawn: '2013-03-05T04:02:17Z',
      dusk: '2013-03-05T16:19:36Z',
      nautical_dawn: '2013-03-05T03:24:31Z',
      nautical_dusk: '2013-03-05T16:57:22Z',
      night_end: '2013-03-05T02:46:17Z',
      night_start: '2013-03-05T17:35:36Z',
      golden_hour_end: '2013-03-05T05:19:01Z',
      golden_hour_start: '2013-03-05T15:02:52Z'
    }
    sun_times = SunCalc.sun_times(@date, @lat, @lng)
    assert_equal sun_times.length, expected_events_and_times.length
    sun_times.each do |event, time|
      expected_time = Time.iso8601(expected_events_and_times[event])
      assert_equal time.to_i, expected_time.to_i
    end
  end

  def test_moon_position
    moon_position = SunCalc.moon_position(@date, @lat, @lng)
    assert_in_delta moon_position[:azimuth], -0.9783999522438226, 1E-15
    assert_in_delta moon_position[:altitude], 0.014551482243892251, 1E-15
    assert_in_delta moon_position[:distance], 364_121.37256256194, 1E-15
  end

  def test_moon_times
    expected_events_and_times = {
      lunar_noon: '2013-03-04T03:17:14Z',
      nadir: '2013-03-04T15:52:51Z',
      moonrise: '2013-03-04T23:54:29Z',
      moonset: '2013-03-04T07:47:58Z'
    }
    moon_times = SunCalc.moon_times(
      Time.iso8601('2013-03-04T00:00:00Z'), @lat, @lng
    )
    assert_equal moon_times.length, expected_events_and_times.length
    moon_times.each do |event, time|
      expected_time = Time.iso8601(expected_events_and_times[event])
      assert_equal time.to_i, expected_time.to_i
    end
  end

  def test_moon_illumination
    moon_illumination = SunCalc.moon_illumination(@date)
    assert_in_delta moon_illumination[:fraction], 0.4848068202456373, 1E-15
    assert_in_delta moon_illumination[:phase], 0.7548368838538762, 1E-15
    assert_in_delta moon_illumination[:angle], 1.6732942678578346, 1E-15
  end
end

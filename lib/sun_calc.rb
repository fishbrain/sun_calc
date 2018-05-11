# frozen_string_literal: true

require 'time'

require 'sun_calc/constants'
require 'sun_calc/helpers'

# SunCalc provides methods for calculating sun/moon positions and phases.
#
# Most of the formulas are based on:
# - http://aa.quae.nl/en/reken/zonpositie.html
# - http://aa.quae.nl/en/reken/hemelpositie.html
class SunCalc
  extend Helpers

  # Sun times configuration (angle, morning name, evening name).
  DEFAULT_SUN_TIMES = [
    [-0.833, 'sunrise', 'sunset'],
    [-0.3, 'sunrise_end', 'sunset_start'],
    [-6, 'dawn', 'dusk'],
    [-12, 'nautical_dawn', 'nautical_dusk'],
    [-18, 'night_end', 'night_start'],
    [6, 'golden_hour_end', 'golden_hour_start']
  ].freeze

  @__sun_times__ = DEFAULT_SUN_TIMES.dup

  # Calculates sun position for a given date, latitude, and longitude.
  def self.sun_position(date, lat, lng)
    lw  = ONE_RADIAN * -lng
    phi = ONE_RADIAN * lat
    d   = to_days(date)
    c   = sun_coords(d)
    h   = sidereal_time(d, lw) - c[:ra]
    { azimuth: azimuth(h, phi, c[:dec]),
      altitude: altitude(h, phi, c[:dec]) }
  end

  # Calculates sun times for a given date, latitude, and longitude.
  def self.sun_times(date, lat, lng)
    lw     = ONE_RADIAN * -lng
    phi    = ONE_RADIAN * lat
    d      = to_days(date)
    n      = julian_cycle(d, lw)
    ds     = approx_transit(0, lw, n)
    m      = solar_mean_anomaly(ds)
    l      = ecliptic_longitude(m)
    dec    = declination(l, 0)
    j_noon = solar_transit_j(ds, m, l)
    { solar_noon: from_julian(j_noon),
      nadir: from_julian(j_noon - 0.5) }.tap do |result|
      @__sun_times__.each do |time|
        begin
          j_set = get_set_j(time[0] * ONE_RADIAN, lw, phi, dec, n, m, l)
          j_rise = j_noon - (j_set - j_noon)
          result[time[1].to_sym] = from_julian(j_rise)
          result[time[2].to_sym] = from_julian(j_set)
        rescue Math::DomainError
          result[time[1].to_sym] = nil
          result[time[2].to_sym] = nil
        end
      end
    end
  end

  # Adds a custom time to the times configuration.
  def self.add_sun_time(angle, rise_name, set_name)
    @__sun_times__.push([angle, rise_name, set_name])
  end

  # Calculates moon position for a gived date, latitude, and longitude.
  def self.moon_position(date, lat, lng)
    lw  = ONE_RADIAN * -lng
    phi = ONE_RADIAN * lat
    d   = to_days(date)
    c   = moon_coords(d)
    h_  = sidereal_time(d, lw) - c[:ra]
    h   = altitude(h_, phi, c[:dec])
    # Formula 14.1 from "Astronomical Algorithms" 2nd edition by Jean Meeus
    # (Willmann-Bell, Richmond) 1998.
    pa  = Math.atan2(Math.sin(h_),
                     Math.tan(phi) * Math.cos(c[:dec]) -
                       Math.sin(c[:dec]) * Math.cos(h_))
    h += astro_refraction(h) # altitude correction for refraction

    { azimuth: azimuth(h_, phi, c[:dec]),
      altitude: h,
      distance: c[:dist],
      parallacticAngle: pa }
  end

  # Calculates moon times for a given date, latitude, and longitude.
  #
  # Calculations for moon rise and set times are based on:
  # - http://www.stargazing.net/kepler/moonrise.html
  def self.moon_times(date, lat, lng)
    t = Time.utc(date.year, date.month, date.day)
    hc = 0.133 * ONE_RADIAN
    h0 = SunCalc.moon_position(t, lat, lng)[:altitude] - hc
    ye = 0
    max = nil
    min = nil
    rise = nil
    set = nil
    # Iterate in 2-hour steps checking if a 3-point quadratic curve crosses zero
    # (which means rise or set). Assumes x values -1, 0, +1.
    (1...24).step(2).each do |i|
      h1 = SunCalc.moon_position(hours_later(t, i), lat, lng)[:altitude] - hc
      h2 = SunCalc.moon_position(
        hours_later(t, i + 1), lat, lng
      )[:altitude] - hc
      a = (h0 + h2) / 2 - h1
      b = (h2 - h0) / 2
      xe = -b / (2 * a)
      ye = (a * xe + b) * xe + h1
      d = b * b - 4 * a * h1
      roots = 0
      x1 = 0
      x2 = 0
      min = i + xe if xe.abs <= 1 && ye < 0
      max = i + xe if xe.abs <= 1 && ye > 0
      if d >= 0
        dx = Math.sqrt(d) / (a.abs * 2)
        x1 = xe - dx
        x2 = xe + dx
        roots += 1 if x1.abs <= 1
        roots += 1 if x2.abs <= 1
        x1 = x2 if x1 < -1
      end
      if roots == 1
        if h0 < 0
          rise = i + x1
        else
          set = i + x1
        end
      elsif roots == 2
        rise = i + (ye < 0 ? x2 : x1)
        set = i + (ye < 0 ? x1 : x2)
      end
      break if rise && set && min && max
      h0 = h2
    end
    {}.tap do |result|
      result[:nadir] = hours_later(t, min) if min
      result[:lunar_noon] = hours_later(t, max) if max
      result[:moonrise] = hours_later(t, rise) if rise
      result[:moonset] = hours_later(t, set) if set
      result[ye > 0 ? :always_up : :always_down] = true if !rise && !set
    end
  end

  # Calculates illumination parameters for the moon for a given date.
  #
  # Formulas are based on:
  # - http://idlastro.gsfc.nasa.gov/ftp/pro/astro/mphase.pro
  # - Chapter 48 of "Astronomical Algorithms" 2nd edition by Jean Meeus
  #   (Willmann-Bell, Richmond) 1998.
  def self.moon_illumination(date = Time.now)
    d = to_days(date)
    s = sun_coords(d)
    m = moon_coords(d)
    sdist = 149_598_000 # Distance from Earth to Sun in kilometers
    phi = Math.acos(Math.sin(s[:dec]) * Math.sin(m[:dec]) +
               Math.cos(s[:dec]) * Math.cos(m[:dec]) * Math.cos(s[:ra] -
                                                                m[:ra]))
    inc = Math.atan2(sdist * Math.sin(phi), m[:dist] - sdist * Math.cos(phi))
    angle = Math.atan2(Math.cos(s[:dec]) * Math.sin(s[:ra] - m[:ra]),
                       Math.sin(s[:dec]) * Math.cos(m[:dec]) -
                         Math.cos(s[:dec]) * Math.sin(m[:dec]) *
                           Math.cos(s[:ra] - m[:ra]))
    { fraction: (1 + Math.cos(inc)) / 2,
      phase: 0.5 + 0.5 * inc * (angle < 0 ? -1 : 1) / Math::PI,
      angle: angle }
  end
end

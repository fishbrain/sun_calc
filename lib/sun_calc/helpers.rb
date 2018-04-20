# frozen_string_literal: true

class SunCalc
  # :nodoc:
  module Helpers
    def to_julian(date)
      date.to_f / ONE_DAY_IN_SECONDS - 0.5 + J1970
    end

    def from_julian(j)
      Time.at((j + 0.5 - J1970) * ONE_DAY_IN_SECONDS).utc
    end

    def to_days(date)
      to_julian(date) - J2000
    end

    def right_ascension(l, b)
      Math.atan2(
        Math.sin(l) * Math.cos(OBLIQUITY_OF_THE_EARTH) -
          Math.tan(b) * Math.sin(OBLIQUITY_OF_THE_EARTH),
        Math.cos(l)
      )
    end

    def declination(l, b)
      Math.asin(Math.sin(b) * Math.cos(OBLIQUITY_OF_THE_EARTH) +
        Math.cos(b) * Math.sin(OBLIQUITY_OF_THE_EARTH) * Math.sin(l))
    end

    def azimuth(h, phi, dec)
      Math.atan2(Math.sin(h),
                 Math.cos(h) * Math.sin(phi) - Math.tan(dec) * Math.cos(phi))
    end

    def altitude(h, phi, dec)
      Math.asin(Math.sin(phi) * Math.sin(dec) +
                Math.cos(phi) * Math.cos(dec) * Math.cos(h))
    end

    def sidereal_time(d, lw)
      ONE_RADIAN * (280.16 + 360.9856235 * d) - lw
    end

    def astro_refraction(h)
      # The following formula works for positive altitudes only.
      h = 0 if h < 0
      # Based on forumla 16.4 of "Astronomical Algorithms" 2nd edition by Jean
      # Meeus (Willmann-Bell, Richmond) 1998.
      0.0002967 / Math.tan(h + 0.00312536 / (h + 0.08901179))
    end

    def solar_mean_anomaly(d)
      ONE_RADIAN * (357.5291 + 0.98560028 * d)
    end

    def ecliptic_longitude(m)
      # Equation of center.
      c = ONE_RADIAN * (1.9148 * Math.sin(m) +
                        0.02 * Math.sin(2 * m) + 0.0003 * Math.sin(3 * m))
      # Perihelion of Earth.
      p = ONE_RADIAN * 102.9372
      m + c + p + Math::PI
    end

    def sun_coords(d)
      m = solar_mean_anomaly(d)
      l = ecliptic_longitude(m)
      { dec: declination(l, 0),
        ra: right_ascension(l, 0) }
    end

    def julian_cycle(d, lw)
      (d - J0 - lw / (2 * Math::PI)).round
    end

    def approx_transit(ht, lw, n)
      J0 + (ht + lw) / (2 * Math::PI) + n
    end

    def solar_transit_j(ds, m, l)
      J2000 + ds + 0.0053 * Math.sin(m) - 0.0069 * Math.sin(2 * l)
    end

    def hour_angle(h0, phi, dec)
      Math.acos(
        (Math.sin(h0) - Math.sin(phi) * Math.sin(dec)) /
        (Math.cos(phi) * Math.cos(dec))
      )
    end

    def get_set_j(h0, lw, phi, dec, n, m, l)
      w = hour_angle(h0, phi, dec)
      a = approx_transit(w, lw, n)
      solar_transit_j(a, m, l)
    end

    def moon_coords(d)
      # Geocentric ecliptic coordinates of the moon
      l  = ONE_RADIAN * (218.316 + 13.176396 * d) # ecliptic longitude
      m  = ONE_RADIAN * (134.963 + 13.064993 * d) # mean anomaly
      f  = ONE_RADIAN * (93.272 + 13.229350 * d)  # mean distance
      l += ONE_RADIAN * 6.289 * Math.sin(m) # longitude
      b  = ONE_RADIAN * 5.128 * Math.sin(f) # latitude
      dt = 385_001 - 20_905 * Math.cos(m) # distance to the moon in km
      { ra: right_ascension(l, b),
        dec: declination(l, b),
        dist: dt }
    end

    def hours_later(date, h)
      Time.at(date.to_f + h * ONE_DAY_IN_SECONDS / 24).utc
    end
  end
end

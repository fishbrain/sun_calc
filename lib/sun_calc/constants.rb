# frozen_string_literal: true

class SunCalc
  ONE_RADIAN = Math::PI / 180
  ONE_DAY_IN_SECONDS = 60 * 60 * 24
  J0 = 0.0009
  J1970 = 2_440_588
  J2000 = 2_451_545
  OBLIQUITY_OF_THE_EARTH = ONE_RADIAN * 23.4397
end

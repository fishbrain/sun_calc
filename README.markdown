# sun\_calc

[![CI Status](https://github.com/fishbrain/sun_calc/workflows/CI/badge.svg)](https://github.com/fishbrain/sun_calc/actions)

A Ruby library, translated from the
[SunCalc](https://github.com/mourner/suncalc) JavaScript library, for
calculating sun positions, sunlight phases, moon positions, and lunar phase for
a given time and location.

## Installing

```
gem install sun_calc
```

## Using

```ruby
require 'sun_calc'
SunCalc.sun_position(Time.now, 59.3345, 18.0662)
#=> {:azimuth=>0.5724083892517442, :altitude=>0.6713233729313038}
```

The library shares a similar API as the JavaScript library.

| JavaScript        | Ruby            |
|-------------------|-----------------|
| `getPosition`     | `sun_position`  |
| `getTimes`        | `sun_times`     |
| `addTime`         | `add_sun_time`  |
| `getMoonPosition` | `moon_position` |
| `getMoonTimes`    | `moon_times`    |

## Maintainer

- Alexander Cederblad (<mailto:alexander@fishbrain.com>)

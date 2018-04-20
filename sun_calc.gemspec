# frozen_string_literal: true

require './lib/sun_calc/version'

Gem::Specification.new do |s|
  s.name     = 'sun_calc'
  s.version  = SunCalc::VERSION
  s.summary  = 'Library for calculating sun/moon positions and phases.'
  s.authors  = ['Alexander Cederblad', 'Fishbrain AB']
  s.email    = ['alexander@fishbrain.com', 'developer@fishbrain.com']
  s.files    = Dir['lib/**/*.rb', 'LICENSE', 'README.markdown']
  s.homepage = 'https://www.github.com/fishbrain/sun_calc'
  s.license  = 'MIT'
end

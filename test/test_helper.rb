# frozen_string_literal: true

if ENV['CI'] || ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start do
    add_filter '/test/'
    enable_coverage :branch
  end
end

require 'minitest/autorun'

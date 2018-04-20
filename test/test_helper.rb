# frozen_string_literal: true

if ENV['CI'] || ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start do
    add_filter '/test/'
  end
end

require 'minitest/autorun'

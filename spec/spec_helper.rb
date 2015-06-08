require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'codebreaker'

module Helpers
  # Replace standard input with faked one StringIO.
  def fake_stdin(*args)
    begin
      $stdin = StringIO.new
      $stdin.puts(args.shift) until args.empty?
      $stdin.rewind
      yield
    ensure
      $stdin = STDIN
    end
  end
end

RSpec.configure do |conf|
  conf.include(Helpers)
end

if ENV['CIRCLE_ARTIFACTS']
  require 'simplecov'
  dir = File.join("..", "..", "..", ENV['CIRCLE_ARTIFACTS'], "coverage")
  SimpleCov.coverage_dir(dir)
end

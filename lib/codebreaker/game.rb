require 'codebreaker/player'
require 'codebreaker/matcher'

module Codebreaker
  class Game
    GIVEN_ATTEMPTS = 10
    CODE_LENGTH = 4
    DIGIT_RANGE = 1..6

    attr_reader :available_attempts, :complete

    def initialize
      @secret_code = (1..CODE_LENGTH).map { rand DIGIT_RANGE }
      @available_attempts = GIVEN_ATTEMPTS
      @complete = 0
    end

    def guess(code_str)
      return 'No available attempts.' if @available_attempts.zero?
      @available_attempts -= 1

      code = code_str.each_char.map { |ch| ch.to_i }      
      matcher = Matcher.new(@secret_code, code)
      matcher.calc     
      
      result = '+' * matcher.exact_match + '-' * matcher.just_match

      complete = matcher.exact_match * (100 / CODE_LENGTH)
      @complete = complete if complete > @complete

      return result
    end

    def cheat
      @secret_code.join
    end

    def hint
      return @hint if @hint
      result = '****'
      pos = rand(@secret_code.size)
      result[pos] = @secret_code[pos].to_s

      return @hint = result
    end

  end
end
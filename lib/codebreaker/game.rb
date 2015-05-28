require 'codebreaker/player'

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

      data = @secret_code.zip(code)
      result = ''
      # Delete all matches
      data.delete_if do |item1, item2|
        if item1 == item2
          result << '+'
        end
      end

      # Start search for '-' if
      # there is still some data
      unless data.empty?
        data, code = data.transpose
        code.each do |item|
          pos = data.index(item)
          if pos
            result << '-'
            data.delete_at pos
          end
        end
      end

      complete = result.count('+') * (100 / CODE_LENGTH)
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
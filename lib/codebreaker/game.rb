require 'codebreaker/player'

module Codebreaker
  class Game
    attr_reader :available_attempts

    def initialize
      @secret_code = (1..4).map { rand 1..6 }
      @has_hint = true
      @available_attempts = 10
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

      return result
    end

    def cheat
      @secret_code.join
    end

    def hint
      return 'No hint available.' unless @has_hint
      @has_hint = false

      result = '****'
      pos = rand(@secret_code.size)
      result[pos] = @secret_code[pos].to_s

      return result
    end

    def self.render_score_table
      collection = Player.load_collection
      if collection.empty?
        puts "No players."
        return
      end

      puts "|--------------------------------------|"
      puts "|--#---Username---Attempts---Complete--|"
      puts "|--------------------------------------|"

      collection.each_with_index do |player, index|
        puts "|%3d  %10s %9d %11d%%|" % [index+1, player.username, player.attempts, player.complete]
        puts "|--------------------------------------|"
      end
    end


  end
end
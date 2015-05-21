require 'codebreaker/player'

module Codebreaker
  class Game
    def initialize
      @secret_code = (1..4).map { rand 1..6 }
      @has_hint = true
      @available_attempts = 10
    end

    def start
      puts "Welcome to the Codebreaker game."
      while @available_attempts > 0
        puts "Type your guess or ? for hint or empty to quit:"
        command = gets.to_s.chomp.strip
        if command == '?'
          puts hint
        elsif command == 'iddqd'
          puts cheat
        elsif command.empty?
          puts "Goodbye"
          return
        else
          guess_result = guess command
          puts guess_result
          if guess_result == "++++"
            win()
            return
          end
        end
      end
    end

    def guess(code_str)
      return 'No available attempts.' if @available_attempts.zero?
      @available_attempts -= 1

      code = code_str.each_char.map { |ch| ch.to_i }

      data = @secret_code.zip(code)
      result = ''
      # Delete all matches
      data.delete_if do |item1,item2|
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

      collection.each_with_index do |player,index|
        puts "|%3d  %10s %9d %11d%%|" % [index+1, player.username, player.attempts, player.complete]
        puts "|--------------------------------------|"
      end
    end

    private
    def save_score
      puts "Do you want to save your score? (yes or no)"
      command = gets.to_s.chomp.strip
      if command == "yes"
        puts "Enter your name:"
        username = gets.to_s.chomp.strip
        Player.add_to_collection Player.new(username, 10 - @available_attempts, 100)
        puts "Your score is saved."
        Game.render_score_table
      end
    end

    def win
      puts "You won!"
      save_score
    end
  end
end
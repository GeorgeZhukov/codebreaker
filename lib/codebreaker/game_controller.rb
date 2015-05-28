require "codebreaker/game"

module Codebreaker
  class GameController
    def initialize
      @game = Game.new
    end

    def start
      puts "Welcome to the Codebreaker game."
      while @game.available_attempts > 0
        puts "Type your guess or ? for hint or empty to quit:"
        command = gets.to_s.chomp.strip
        case command
          when '?'
            puts @game.hint
          when "iddqd"
            puts @game.cheat
          when /^[1-6]{4}$/
            guess_result = @game.guess command
            puts guess_result
            if guess_result == "++++" or @game.available_attempts.zero?
              puts "You won!" if guess_result == "++++"
              save_score
              return
            end
          when ""
            puts "Goodbye"
            return
          else
            puts "Unknown command."
        end

      end
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

    private
    def save_score
      puts "Do you want to save your score? (yes or no)"
      command = gets.to_s.chomp.strip
      if command == "yes"
        puts "Enter your name:"
        username = gets.to_s.chomp.strip
        Player.add_to_collection Player.new(username, Game::GIVEN_ATTEMPTS - @game.available_attempts, @game.complete)
        puts "Your score is saved."
        GameController.render_score_table
      end
    end

  end
end
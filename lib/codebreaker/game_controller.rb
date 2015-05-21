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
            if guess_result == "++++"
              win()
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

    private
    def save_score
      puts "Do you want to save your score? (yes or no)"
      command = gets.to_s.chomp.strip
      if command == "yes"
        puts "Enter your name:"
        username = gets.to_s.chomp.strip
        Player.add_to_collection Player.new(username, 10 - @game.available_attempts, 100)
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
module Codebreaker
  class Matcher
    attr_reader :exact_match, :just_match
    
    def initialize(secret_code, guess_code)
      @secret_code = secret_code
      @guess_code = guess_code
      @exact_match = 0      
      @just_match = 0
    end
    
    def calc
      calc_exact_match
      calc_just_match
    end
    
    private
    
    def calc_exact_match
      data = @secret_code.zip(@guess_code)
      data.delete_if { |secret_code_item, guess_code_item| @exact_match += 1 if secret_code_item == guess_code_item }
      @secret_code, @guess_code = data.transpose
    end
    
    def calc_just_match
      return if @guess_code.nil?
      @guess_code.each do |guess_code_item|
        pos = @secret_code.index(guess_code_item)
        if pos
          @just_match += 1
          @secret_code.delete_at pos
        end
      end      
    end
    
  end
end
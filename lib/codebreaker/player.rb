module Codebreaker
  class Player
    COLLECTION_FILENAME = "players.bin"

    attr_reader :username, :attempts, :complete

    def initialize(username, attempts, complete)
      @username = username
      @attempts = attempts
      @complete = complete
    end

    def to_s
      "#{@username}, Attempts: #{@attempts}, Complete: #{@complete}%"
    end

    def self.load_collection
      return [] unless File.exist?(COLLECTION_FILENAME)
      raw_data = File.read COLLECTION_FILENAME
      collection = Marshal.load raw_data

      # Sort by attempts ascending and complete descending
      collection.sort! do |a,b|
        [a.attempts, b.complete] <=> [b.attempts, a.complete]
      end
      return collection
    end

    def self.add_to_collection(player)
      collection = load_collection
      collection << player
      raw_data = Marshal.dump collection
      File.write(COLLECTION_FILENAME, raw_data)
    end
  end
end
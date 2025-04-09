module Hangman
  class Game
    def self.get_words
      path = File.expand_path('../words/google-10000-english-no-swears.txt', __dir__)
      # makes file path-independent
      words = File.open(path)
      filtered = words.select { |line| line.chomp.length > 4 && line.chomp.length < 13 }
      words.close
      filtered.each { |line| puts line}
    end
  end
end
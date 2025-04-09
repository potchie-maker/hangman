module Hangman
  class Game
    def get_words
      path = File.expand_path('../words/google-10000-english-no-swears.txt', __dir__)
      # makes file path-independent
      File.open(path) do |words|
        filtered = words.map(&:chomp).select { |line| line.chomp.length.between?(5, 12) }
        # filtered.each { |line| puts line}
      end
    end

    def secret_word
      secret_word = self.get_words.sample
      secret_word
    end
  end
end
module Hangman
  class Game
    attr_accessor :attempts, :save_secret, :save_wrong_guesses, :save_word_progress, :save_remaining_tries
    
    def initialize
      @attempts = 100
    end

    def play_game
      puts "\nWelcome to Hangman!"
      secret_word = self.secret_word

      self.save_secret = secret_word

      guess = ''
      wrong_guesses = []
      filled_in = Array.new(secret_word.length, '_')
      until secret_word == filled_in.join || attempts == 0
        guess = self.get_guess
        if good_guess?(secret_word, guess)
          puts "\nYou guessed a correct letter"
          filled_in = self.show_progress(secret_word, guess, filled_in)
        else
          self.attempts -= 1
          puts "\nThat letter is not in the word."
          puts "\nYou have #{attempts} tries remaining"

          self.save_remaining_tries = attempts

          filled_in = self.show_progress(secret_word, guess, filled_in)
          
          unless wrong_guesses.include?(guess)
            wrong_guesses << guess
          end
        end
        puts "\nYour current wrong guesses are: #{wrong_guesses.join(", ")}"

        self.save_word_progress = filled_in
        self.save_wrong_guesses = wrong_guesses
      end
    end

    def get_words
      path = File.expand_path('../words/google-10000-english-no-swears.txt', __dir__)
      # makes file path-independent
      File.open(path) do |words|
        words.map(&:chomp).select { |line| line.chomp.length.between?(5, 12) }
      end
    end

    def secret_word
      secret_word = self.get_words.sample
      secret_word
    end

    def hide_word(word)
      blanks = word.chars.map { "_" }
      blanks
    end

    def get_guess
      puts "\nGuess a letter!\n\n"
      chosen = gets.chomp
      until chosen.match?(/^[a-zA-Z]$/)
        puts "\nInvalid input."
        puts "Example input: 'a' or 'A'"
        puts ""
        chosen = gets.chomp
      end
      # puts "\nYou guessed the letter: #{chosen}"
      chosen.downcase
    end

    def show_progress(word, guess, blanks = Array.new(word.length, '_'))
      word.each_char.with_index do |letter, i|
        if letter == guess
          blanks[i] = guess
        end
      end
      puts ''
      puts blanks.join(" ")
      blanks
    end

    def good_guess?(word, guess)
      word.include?(guess)
    end
  end

  class Save
    def initialize(secret_word, incorrect_guesses,correct_guesses,lives_left)
      @secret_word = secret_word
      @incorrect_guesses = incorrect_guesses
      @correct_guesses = correct_guesses
      @lives_left = lives_left
    end
  end
end
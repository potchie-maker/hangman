require 'json'

module Hangman
  class Game
    attr_accessor :secret, :wrong_guesses, :word_progress, :remaining_tries
    
    def initialize(secret: nil, wrong_guesses: [], word_progress: nil, remaining_tries: 6)
      @secret = secret || secret_word
      @wrong_guesses = wrong_guesses
      @word_progress = word_progress || Array.new(@secret&.length || 0, '_')
      @remaining_tries = remaining_tries
    end

    def play_game
      puts "\nWelcome to Hangman!"

      puts "Secret word loaded: #{self.secret}"

      until self.secret == self.word_progress.join || self.remaining_tries == 0
        guess = self.get_guess
        if good_guess?(self.secret, guess)
          puts "\nYou guessed a correct letter"
          self.word_progress = self.show_progress(self.secret, guess, self.word_progress)
        else
          self.remaining_tries -= 1
          puts "\nThat letter is not in the word."

          self.word_progress = self.show_progress(self.secret, guess, self.word_progress)
          
          unless self.wrong_guesses.include?(guess)
            self.wrong_guesses << guess
          end
        end
        puts "\nYou have #{self.remaining_tries} tries remaining"
        puts "\nYour current wrong guesses are: #{self.wrong_guesses.join(", ")}"

        if save_option == true
          break
        end
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

    def save_option
      puts "\nWould you like to save this game? (y/n)\n\n"
      saved = nil
      choice = gets.chomp
      until choice.match?(/^[yYnN]$/)
        puts "\nInvalid input."
        puts "Example input: 'y' or 'n'"
        puts ""
        choice = gets.chomp
      end

      if choice.downcase == 'y'
        puts "\nInput file name:\n\n"
        filename = gets.chomp.gsub(/\s+/, '_').gsub(/[^0-9A-Za-z_\-]/, '')
        SaveManager.save(self, filename)
        saved = true
      elsif choice.downcase == 'n'
        puts "\nContinue current game.\n\n"
      end
      saved
    end

    def load_option
      puts "\nWould you like to load a saved game? (y/n)\n\n"
      choice = gets.chomp
      until choice.match?(/^[yYnN]$/)
        puts "\nInvalid input."
        puts "Example input: 'y' or 'n'"
        puts ""
        choice = gets.chomp
      end

      if choice.downcase == 'y'
        saves = SaveManager.list_saves
        if saves.empty?
          puts "\nNo saved games found. Starting new game."
          self.play_game
          return
        end

        puts "\nAvailable saves:"
        saves.each_with_index { |save, i| puts "#{i + 1}. #{save}" }

        puts "\nEnter the number of the desired save file:"
        selection = gets.chomp.to_i

        until selection.between?(1, saves.size)
          puts "\nInvalid selection. Choose a number from the list:"
          selection = gets.chomp.to_i
        end

        filename = saves[selection - 1]
        SaveManager.load(filename).play_game
      else
        puts "\nStarting new game!\n\n"
        self.play_game
      end
    end

    def to_h
      {
        secret: @secret,
        wrong_guesses: @wrong_guesses,
        word_progress: @word_progress,
        remaining_tries: @remaining_tries
      }
    end

    def self.from_h(data)
      new(
        secret: data[:secret],
        wrong_guesses: data[:wrong_guesses],
        word_progress: data[:word_progress],
        remaining_tries: data[:remaining_tries]
      )
    end
  end

  class SaveManager
    SAVE_DIR = File.expand_path('../saves', __dir__)

    def self.save(game, filename)
      filename = "hangman_save" if filename.nil? || filename.strip.empty?
      FileUtils.mkdir_p(SAVE_DIR) unless Dir.exist?(SAVE_DIR)
      save_path = File.join(SAVE_DIR, "#{filename}.json")
      File.write(save_path, JSON.pretty_generate(game.to_h))
      puts "\nGame successfully saved to #{save_path}"
    end
  
    def self.load(filename = "hangman_save")
      save_path = File.join(SAVE_DIR, "#{filename}.json")
      if File.exist?(save_path)
        data = JSON.parse(File.read(save_path), symbolize_names: true)
        puts "Loaded data: #{data.inspect}"
        Game.from_h(data)
      else
        puts "\nNo saved game found."
        nil
      end
    end

    def self.list_saves
      FileUtils.mkdir_p(SAVE_DIR) unless Dir.exist?(SAVE_DIR)
      Dir.entries(SAVE_DIR).select { |f| f.end_with?('.json') }.map { |f| File.basename(f, '.json') }
    end
  end
end
#!/usr/bin/env ruby

# Anagrams v0.1
# Written by Ishaan during a Shinkansen ride from Tokyo to Shin-Osaka
# Based on the word game from Pulak (thanks Pulak!)

def minus(a,b)
  result = a.dup
  for char in b
    result.delete_at(result.index(char)) if result.index(char)
  end
  result
end

def subset(little, big)
  minus(big,little).count == big.count - little.count
end

unflipped = '
  kjxqzffhhvvwwyyppmmccbbgggdddduuuussssllllnnnnnn
  rrrrrrttttttooooooooaaaaaaaaaiiiiiiiiieeeeeeeeeeee
  '.gsub(/\s/,'').upcase.chars.shuffle
flipped = []
players = []

puts "How many players?"
(gets.to_i).times do
  players << []
end

until unflipped.empty? && flipped.empty?

  # Print current game state
  
  if flipped.empty?
    puts "No flipped tiles."
  else
    puts "Flipped tiles: #{flipped.join(',')}"
  end

  players.each_with_index do |player, i|
    puts "Player #{i}:"
    puts "(nothing)" if player.empty?
    for word in player
      puts "   #{word.join('')}"
    end
  end

  # Accept input in the form of [player #][word played]
  # Empty input means "flip a tile"

  case (input = gets.strip)
  when /([0-9])([a-z]+)/
    player = $1.to_i
    word = $2.chars

    puts "Player #{player} played '#{word.join('')}'."

    # Figure out whether the word can be made by stealing a word from elsewhere
    best_cand = nil
    players.each_with_index do |opponent, i|
      candidates = opponent.
          select {|stolen_word| subset(stolen_word, word)}.
          sort_by { |e| e.count }
      if !candidates.empty? && (!best_cand || candidates[0].count > best_cand[:word].count)
        best_cand = {word: candidates[0], player: i}
      end
    end

    claimed_chars = best_cand ? minus(word, best_cand[:word]) : word

    # Check move validity (i.e. can the word be formed from available letters?)
    if subset(claimed_chars, flipped)
      if best_cand
        players[best_cand[:player]].delete(best_cand[:word])
        puts "'#{best_cand[:word].join('')}' stolen from player #{best_cand[:player]}!"
      end
      # Add the word to the player's words, and remove any used common tiles
      players[player] << word
      flipped = minus(flipped, claimed_chars)
    else
      puts "Invalid move!"
    end

  else
    # Flip a tile
    if unflipped.empty?
      puts "No more unflipped tiles!"
    else
      flipped << unflipped.pop
      puts "Flipped '#{flipped.last}'."
    end

  end # possible inputs
end # game loop

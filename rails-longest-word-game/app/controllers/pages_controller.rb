require 'open-uri'
require 'json'

API_URL = 'https://api-platform.systran.net/translation/text/translate'
API_KEY = 'b60ca62d-1ee4-4868-97cc-17dab138aef7'
URL = "#{API_URL}?source=en&target=fr&key=#{API_KEY}"

class PagesController < ApplicationController



  def generate_grid(grid_size)
    grid = []
    grid_size.times do
      grid << "QWERTYUIOPASDFGHJKLZXCVBNM".split('').sample
    end
    grid
  end

  def translator(attempt)
    url = URL + "&input=" + attempt
    translator_hash = JSON.parse(open(url).read)
    if translator_hash["outputs"][0]["output"] == attempt
      nil
    else
      translator_hash["outputs"][0]["output"]
    end
  end

  def word_in_grid?(word, grid)
    # (word.upcase.split('') - grid).empty? ? true : false
    hash_grid = {}
    grid.each do |letter|
      hash_grid.key?(letter) ? hash_grid[letter] += 1 : hash_grid[letter] = 1
    end
    hash_word = {}
    word.upcase.chars.each { |letter| hash_word.key?(letter) ? hash_word[letter] += 1 : hash_word[letter] = 1 }

    hash_word.each do |letter, value|
      return false if (hash_grid[letter] && (value > hash_grid[letter])) || hash_grid[letter].nil?
    end
    true
  end

  def scorer(attempt, time)
    ((attempt.size * 15) - (time / 2))
  end

  def messager(score)
    if score >= 50     #   SCOOOORE
      "well done"
    elsif 20 < score   #   SCOOOORE
      "mediocre"
    else
      "poor"
    end
  end

  def game
    @grid = generate_grid(9)
  end

  def score
    @in_grid = word_in_grid?(params[:answer], params[:grid].split("")) #how to get the answer value?
    @answer = params[:answer]
    @score = scorer(params[:answer], (Time.now().to_i - params[:time_start].to_i))
    @message = messager(@score)
    @time = ((Time.now().to_i - params[:time_start].to_i))
    @exists = translator(params[:answer])
  end
end

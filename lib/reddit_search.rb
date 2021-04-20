require 'redd'


def parse_stonks
  puts "Gonna check Reddit for more stonks. Gimme a minute."
  search = RedditSearch.new('wallstbets').run_search
  puts "Got 'em. Hold up, Hold up...."
  handler = SearchHandler.new(search)
  handler.populateStonks
  handler.populateSearch
  puts "Search has been handled man. No problemo."
end


# Uses Reddit API to search for stock symbols.
# search = RedditStonkSearch.new
# search.rising = { :SYM => mentions,... }
class RedditSearch
  def initialize(subreddit = 'all')
    @session = Redd.it(
      user_agent: 'Redd:RandomBot:v1.0.0 (by /u/Mustermind)',
      client_id:  ENV['REDDIT_CLIENT_ID'],
      secret:     ENV['REDDIT_SECRET'],
      username:   ENV['REDDIT_USERNAME'],
      password:   ENV['REDDIT_PASSWORD']
    )
    @regex = /\$([A-Z]{3,5})/
    @subreddit = subreddit
    @counter = StonkCounter.new
  end


  def subreddit
    @session.subreddit(@subreddit)
  end

  def rising
    subreddit.rising.each do |rising|
      rising.inspect.scan(@regex) { |match| matcher(match) }
      if rising.comments.count > 0
        rising.comments.each do |comment|
          comment.inspect.scan(@regex) { |match|  matcher(match) }
        end
      end
    end

  end

  def run_search
    rising

    return results
  end

  def results
    @counter.stocks
  end

  # Now that the counting functionality has been removed, this clearly does
  # something, and it does something important, and yet it's still too enmeshed
  # with the rest of the code to allow that functionality to be tested.
  def matcher(match)
    match = match.flatten.uniq
    match.each do |m|
      @counter.count(m)
    end
  end
end

class StonkCounter
  attr_accessor :stocks
  def initialize
    @stocks = {}
  end

  def count(stock)
    if @stocks[stock.to_sym]
      @stocks[stock.to_sym] += 1
    else
      @stocks[stock.to_sym] = 1
    end
  end

end

require 'active_record'
require './models/stonk.rb'
require 'database'

class SearchHandler
  def initialize(search)
    @results = search
  end


  def populateStonks
    @results.keys.each do |stock|
      if Stonk.where(symbol: stock).empty? === true
        then
        s = Stonk.new
        s.symbol = stock
        s.save
      end
    end
  end

  # The tests for this one would be a lot more useful, I realize.
  def populateSearch
    Search.transaction do
      search = Search.new
      @results.keys.each do |key|
        s = search.search_stonks.new
        s.stonk = Stonk.find_by symbol: key
        s.count = @results[key]
      end
      search.save!
    end
  end

end

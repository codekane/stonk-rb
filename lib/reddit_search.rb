require 'redd'

module Reddit
  def self.parse_stonks
    puts "Gonna check Reddit for more stonks. Gimme a minute."
    search = RedditSearch.new('wallstbets').run_search
    puts "Got 'em. Hold up, Hold up...."
    handler = SearchHandler.new(search)
    handler.populateStonks
    handler.populateSearch
    puts "Search has been handled man. No problemo."
  end
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

  # I could improve this to take the top 500, rather than 100.
  # Get even more data.
  def hot_stocks
    handler = @session.subreddit(@subreddit)
    results = handler.hot(limit: 100)

    results.each do |feed|
      feed.inspect.scan(@regex) { |match| matcher(match) }
      if feed.comments.count > 0
        feed.comments(limit: 100).each do |comment|
          comment.inspect.scan(@regex) { |match| matcher(match) }
        end
      end
    end
  end

  def run_search
    hot_stocks

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

# This seems kind of hack-jawed refactored. Oh well.
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


class SearchHandler
  def initialize(search)
    @results = search
  end


  # Likewise important. WOnder if this could go somewhere else though. Like as a model method.
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

  # This seems unimportant, yet it's used by the program. Important.
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

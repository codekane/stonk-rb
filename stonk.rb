require 'redd'
require 'pp'
require 'pry'

class Stonker
  attr_accessor  :matches, :stocks
  def initialize
    @session = Redd.it(
      user_agent: 'Redd:RandomBot:v1.0.0 (by /u/Mustermind)',
      client_id:  ENV['REDDIT_CLIENT_ID'],
      secret:     ENV['REDDIT_SECRET'],
      username:   ENV['REDDIT_USERNAME'],
      password:   ENV['REDDIT_PASSWORD']
    )
    @stocks = {}
    @regex = /\$([A-Z]{3,4})/
    @subreddit = 'wallstbets'
  end

  def matcher(match)
    match = match.flatten.uniq
    match.each do |m|
      if @stocks[m.to_sym]
        @stocks[m.to_sym] += 1
      else
        @stocks[m.to_sym] = 1
      end
    end
  end

  def rising
    @session.subreddit(@subreddit).rising.each do |rising|
      rising.inspect.scan(@regex) { |match| matcher(match) }
      if rising.comments.count > 0
        rising.comments.each do |comment|
          comment.inspect.scan(@regex) { |match|  matcher(match) }
        end
      end
    end
  end
end

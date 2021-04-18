require 'active_record'
require './models/stonk.rb'
require './lib/reddss.rb'

def db_configuration
  db_configuration_file = File.join(File.expand_path('..', __FILE__), 'db', 'config.yml')
  YAML.load(File.read(db_configuration_file))
end

ActiveRecord::Base.establish_connection(db_configuration["development"])


# Populates the Stonk table with all the correct symbols, if they are not
# already there.

class SearchHandler
  def initialize
    @results = ReddSS.new.rising
  end


  # Put something fun here as a put message, with some fun statistics
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

  # Now this has to actually do something
  def new_search
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

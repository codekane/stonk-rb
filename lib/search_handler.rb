require 'active_record'
require './models/stonk.rb'

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

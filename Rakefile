require 'standalone_migrations'
StandaloneMigrations::Tasks.load_tasks
require './stonk.rb'

namespace :stonk do
  task :handle do
    parse_stonks
  end
  def parse_stonks
    puts "Gonna check Reddit for more stonks. Gimme a minute."
    search = RedditSearch.new('wallstbets').run_search
    puts "Got 'em. Hold up, Hold up...."
    handler = SearchHandler.new(search)
    handler.populateStonks
    handler.populateSearch
    puts "Search has been handled man. No problemo."
  end

end

require 'active_record'
require './models/stonk.rb'
require './lib/reddit_search.rb'
require './lib/search_handler.rb'


def db_configuration
  db_configuration_file = File.join(File.expand_path('..', __FILE__), 'db', 'config.yml')
  YAML.load(File.read(db_configuration_file))
end

ActiveRecord::Base.establish_connection(db_configuration["development"])

# This is a copy-paste from the code presently in use in the Rakefile.
# It's presently the best example of the all-together app, though, and,
# presently
# It's looking a bit scarce so this way
# it feels like lonely
def parse_stonks
  puts "Gonna check Reddit for more stonks. Gimme a minute."
  search = RedditSearch.new('wallstbets').run_search
  puts "Got 'em. Hold up, Hold up...."
  handler = SearchHandler.new(search)
  handler.populateStonks
  handler.populateSearch
  puts "Search has been handled man. No problemo."
end


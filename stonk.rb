require 'active_record'
require './models/stonk.rb'
require './models/search.rb'
require './lib/reddss.rb'

def db_configuration
  db_configuration_file = File.join(File.expand_path('..', __FILE__), 'db', 'config.yml')
  YAML.load(File.read(db_configuration_file))
end

ActiveRecord::Base.establish_connection(db_configuration["development"])

search = ReddSS.new.rising

# Populates the Stonk table with all the correct symbols, if they are not
# already there.

search.keys.each do |stock|
  if Stonk.where(symbol: stock).empty? === true
    then
      s = Stonk.new
      s.symbol = stock
      s.save
  end
end

# Next I'm going to want to store the data from this search.
# A search will have an ID, a date, and be related to the stonk tables.
# I think this is a has_many relationship. 
#
# Note that as a part of this script, I want to check that the stonks and counts
# are different than the last time it ran. If it's not, I'll build the object,
# bu then not save. This will give me a really quick way to check how the data
# changes, without having to sift through enormous database tables.

require 'active_record'
require './models/stonk.rb'
require './lib/reddss.rb'

def db_configuration
  db_configuration_file = File.join(File.expand_path('..', __FILE__), 'db', 'config.yml')
  YAML.load(File.read(db_configuration_file))
end

ActiveRecord::Base.establish_connection(db_configuration["development"])

stock = Stonk.new(symbol: "PENIS");
stock.save

search = ReddSS.new.rising

search.keys.each do |stock|
  if Stonk.where(symbol: stock).empty? === true
    then
      s = Stonk.new
      s.symbol = stock
      s.save
  end
end

# What I am receiving is a hash of objects.
# At this stage, I want to iterate over each of the objects, and check to see if
# their key exists as a row in the Stonks table.
# If it does not I want to create it and move on.
# If it does I want to move on.

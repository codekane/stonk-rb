$: << "."
require 'pry'
require_relative './config/environment.rb'
#StandaloneMigrations::Tasks.load_tasks
require './app/reddit_search'
require 'sinatra/activerecord/rake'
require './stonk.rb'


namespace :db do
  task :load_config do
  end
end

namespace :finance do
  namespace :quotes do
    task :collect do
      puts "Beginning 1 day Quote Collection. 1 poll per minute. No error handling. lol."
      YF::Quotes.collect(:all, frequency: 1.minute, duration: 1.day,
                         filename: "first_sunday")
    end
  end
end

namespace :stonk do
  task :handle do
    Search.connection
    stonks = Search.last.stonks
    YF::Quotes.update(stonks)
    YF::Summary.update(stonks)
  end

  task :get_data do
    parse_stonks
  end

end

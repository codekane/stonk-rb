$: << "."
require 'pry'
require_relative './config/environment.rb'
#StandaloneMigrations::Tasks.load_tasks
require './lib/reddit_search'
require 'sinatra/activerecord/rake'
require './stonk.rb'


namespace :db do
  task :load_config do
  end
end

# This was a one-off. It's collected the data I needed. I think it can be commented out now.
# namespace :finance do
#   namespace :quotes do
#     task :collect do
#       puts "Beginning 1 day Quote Collection. 1 poll per minute. No error handling. lol."
#       YF::Quotes.collect(:all, frequency: 1.minute, duration: 1.day,
#                          filename: "first_sunday")
#     end
#   end
# end

namespace :stonk do
  task :handle do
    puts "Beginning YF Cache Update"
    YF::Automation.update_data
  end

  task :get_data do
    # TODO:
    # This should really be inside of a module. It's polluting the global namespace.
    Reddit.parse_stonks
  end

end

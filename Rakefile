$: << "."
require_relative './config/environment.rb'
#StandaloneMigrations::Tasks.load_tasks
#require 'reddit_search'
#require './stonk.rb'
require 'sinatra/activerecord/rake'

namespace :db do
  task :load_config do
    require './stonk.rb'
  end
end

namespace :stonk do
  task :handle do
    parse_stonks
  end

  task :get_data do
    YF.update_stonk_cache
  end


end

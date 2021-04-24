require 'standalone_migrations'
StandaloneMigrations::Tasks.load_tasks
require 'reddit_search'
require './stonk.rb'

namespace :stonk do
  task :handle do
    parse_stonks
  end

  task :get_data do
    YF.update_stonk_cache
  end


end

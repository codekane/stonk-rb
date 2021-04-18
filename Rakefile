require 'standalone_migrations'
StandaloneMigrations::Tasks.load_tasks
require './stonk.rb'

namespace :stonk do
  task :handle do
    search = SearchHandler.new
    search.populateStonks
    search.new_search
    puts "Search has been handled man. No problemo."
  end
end

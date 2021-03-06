# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
job_type :asdf_rake, %Q{. $HOME/.asdf/asdf.sh; . $HOME/.asdf/completions/asdf.bash;\
                        cd :path && direnv exec . rake :task --silent :output}

set :environment, "development"
set :output, "/Users/Scald/Projects/stonk/log.md"
env :PATH, ENV['PATH']

# This part seems to work.
every 1.hour do
  asdf_rake "stonk:get_data"
end

# This part I don't know that it works, honestly.
# TODO: Does this even work?
every 5.minutes do
  asdf_rake "stonk:handle"
end
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

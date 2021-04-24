# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
job_type :asdf_rake, %Q{. $HOME/.asdf/asdf.sh; . $HOME/.asdf/completions/asdf.bash;\
                        cd :path && direnv exec . rake :task --silent :output}

set :output, "/Users/Scald/Projects/stonk/log.md"
every 1.hour do
  asdf_rake "stonk:handle"
end

every 5.minutes do
  asdf_rake "stonk:get_data"
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

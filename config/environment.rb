ENV['RACK_ENV'] ||= 'development'
require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'])

require 'active_record'
require 'redis'
require 'redis-namespace'
require 'sinatra/base'
require 'json'
require './models/stonk.rb'
require 'sinatra/activerecord'
#require 'standalone_migrations'
#require 'reddit_search'

# Set up Database
def db_configuration
  db_configuration_file = File.join(File.expand_path('..', __FILE__), '../db', 'config.yml')
  YAML.load(File.read(db_configuration_file))
end

ActiveRecord::Base.establish_connection(db_configuration[ENV['RACK_ENV']])

# Set up Redis Cache
unless ENV['RACK_ENV'] == 'test'
  REDIS = Redis.new
else
  REDIS = MockRedis.new
end

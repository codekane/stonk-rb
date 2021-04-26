require './config/environment.rb'
require './stonk.rb'
require 'rack'
require 'rack/cors'

use Rack::Cors do |config|
  config.allow do |allow|
    allow.origins '*'
    allow.resource '/api/stonks',
      :methods => [:get, :options],
      :headers => :any,
      :max_age => 0
    allow.resource '/api/summary',
      :methods => [:get, :options],
      :headers => :any,
      :max_age => 0
    allow.resource '/api/quotes',
      :methods => [:get, :options],
      :headers => :any,
      :max_age => 0
  end

end

run APIController

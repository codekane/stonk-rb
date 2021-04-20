require 'active_record'
require 'sinatra/base'
require './lib/database.rb'
require './models/stonk.rb'
require 'json'


class APIController < Sinatra::Base

  get '/api/stonks' do
    content_type 'application/json'

    return Stonk.all.pluck(:symbol).to_json
    # Should respond 200
    # Format should be JSON
    # Response should match a query of Stock.all.symbol:=
    # Should return the symbols for Stock.all in JSON format.

  end

  get 'stonk_data' do

  end
end

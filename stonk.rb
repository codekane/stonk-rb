require 'active_record'
require 'sinatra/base'
require './lib/database.rb'
require './models/stonk.rb'
require 'json'


# Ruby method to act as a pass-through for the stonk_data.py script

module YahooFinance

  def self.get_stonk_data(string)
    output = `python lib/stonk_data.py #{string}`
    return JSON.parse(output)
  end

end



class APIController < Sinatra::Base

  get '/api/stonks' do
    content_type 'application/json'
    return Stonk.all.pluck(:symbol).to_json
  end

  get 'stonk_data' do
  end
end

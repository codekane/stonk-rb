require 'active_record'
require 'sinatra/base'
require './lib/database.rb'
require './models/stonk.rb'
require 'json'
require 'redis'

REDIS = Redis.new


module YF

  def self.api_feed
    stonks = []
    get_stonks.each do |stonk|
      stonks << read_stonk_cache(stonk)
    end
    response = {"stonks": stonks}
    return response
  end


  def self.get_stonks
    return Search.last.stonks.pluck(:symbol)
  end

  def self.get_stonk_data(arg)
    arg = clean_arguments(arg)
    output = `python lib/stonk_data.py #{arg}`
    return JSON.parse(output)
  end

  def self.update_stonk_cache
    get_stonks.each do |stonk|
      data = get_stonk_data(stonk)
      REDIS.set(stonk, data)
    end
  end

  def self.read_stonk_cache(stonk)
    REDIS.get(stonk)
  end

  def self.clean_arguments(arg)
    if arg.class == String
      return arg
    elsif arg.class == Stonk
      return arg.symbol
    elsif arg.class == Array
      parsed = []
      arg.each do |a|
        if a.class == String
          parsed << a
        elsif a.class == Stonk
          parsed << a.symbol
        end
      end
      output = ""
      parsed.each_with_index do |p, index|
        if index == parsed.length - 1
          output += p
        else
          output = output + p + " "
        end
      end
      return output
    end
  end
end


class APIController < Sinatra::Base

  get '/api/stonks' do
    content_type 'application/json'
    return YF.api_feed.to_json
  end

end

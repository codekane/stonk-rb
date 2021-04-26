require './config/environment.rb'
require 'pry'

module YF
  module Helpers
    def symbolize(arg)
      if arg.class == String || arg.class == Symbol || arg.respond_to?(:symbol)
        if arg.respond_to?(:symbol) then arg = arg.symbol end
        return [arg]
      elsif arg.class == Array || arg.respond_to?(:to_ary)
        arg = arg.to_ary
        arg = arg.flatten.select { |a| a.class == String || a.class == Symbol || a.respond_to?(:symbol) }
        arg = arg.map { |a| if a.respond_to?(:symbol) then a = a.symbol else a end }
        arg = arg.map { |a| if a.respond_to?(:to_sym) then a = a.to_sym else a end }
      end
    end
  end

  class API
    include YF::Helpers
    attr_accessor :method
    def initialize(method)
      @method = method
    end

    # Receive a JSON Hash with "response" keyed to an array of results from the query
    def request(args)
      args = prepare_arguments(args)
      response = `python lib/YF.py #{args}`
      return JSON.parse(response)
    end

    # Handles Strings, Symbols, and Objects that respond to '.symbol', as well as Arrays containg these types
    # Returns a string properly formatted for delivering arguments to the python script that handles that actual API connection
    def prepare_arguments(arg)
      if symbolize(arg)
        arg = symbolize(arg)
        return arg.unshift(@method).join(" ")
      end
      # if arg.class == String || arg.class == Symbol || arg.respond_to?(:symbol)
      #   if arg.respond_to?(:symbol) then arg = arg.symbol end
      #   return [@method, arg].join(" ")
      # elsif arg.class == Array
      #   arg = arg.flatten.select { |a| a.class == String || a.class == Symbol || a.respond_to?(:symbol) }
      #   arg = arg.map { |a| if a.respond_to?(:symbol) then a = a.symbol else a end }
      #   return arg.unshift(@method).join(" ")
      # end
    end


  end

  
  # Only one who has the right keys for the API and Cache to get the Summary data
  # Call this class anywhere you need Summary data get/set
  class Summary
    extend YF::Helpers
    attr_accessor :cache, :api
    def initialize
      @cache = YF::Cache.new(namespace)
      @api   = YF::API.new(method)
    end
    def namespace
      :summary
    end
    def method
      :summary_detail
    end

    # This cannot handle multiple arguments, which is bad, as it had really ought to.
    # This needs to replenish the hash keys
    # This needs to accept arrays, etc.
    def self.fetch_cache(stonks)
      summary = Summary.new
      response = []
      if symbolize(stonks)
        stonks = symbolize(stonks)
        stonks.each do |stonk|
          data = {}
          data[stonk] = JSON.parse(summary.cache.get(stonk))
          response << data
        end
      end
      return response
    end

    # Setter method is protected against multiple file types due to the protections I
    # put in place on the API... There is no such protection in play for the others.
    # Need to abstract that piece so it can be re-used
    def self.update_cache(stonks)
      summary = Summary.new
      response = summary.api.request(stonks)["response"]
      response.each do |r|
        if r == "No data found"
          return
        else
          key = r.keys[0]
          summary.cache.set(key, r[key])
        end
      end
    end

  end

  class Quotes < Summary
    def namespace
      :quote
    end
    def method
      :quotes
    end
  end


  class Cache
    def initialize(namespace)
      @redis = Redis::Namespace.new(namespace, redis: REDIS)
    end

    def get(symbol)
      @redis.get(symbol)
    end

    def set(symbol, data)
      @redis.set(symbol, JSON.dump(data))
    end
  end
end


class APIController < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  get '/api/stonks' do
    content_type 'application/json'
    return YF.api_feed.to_json
  end

  get '/api/summary' do
    content_type 'application/json'
    response.headers['Access-Control-Allow-Origin'] = '*'
    @stonks = Search.last.stonks
    return YF::Summary.fetch_cache(@stonks).to_json
  end

  get '/api/quotes' do
    content_type 'application/json'
    response.headers['Access-Control-Allow-Origin'] = '*'
    @stonks = Search.last.stonks
    return YF::Quotes.fetch_cache(@stonks).to_json

  end


  options "*" do
    response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
    response.headers["Access-Control-Allow-Origin"] = "*"
    200
  end


end

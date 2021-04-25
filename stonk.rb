require './config/environment.rb'
require 'pry'

module YF
  class API
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
      if arg.class == String || arg.class == Symbol || arg.respond_to?(:symbol)
        if arg.respond_to?(:symbol) then arg = arg.symbol end
        return [@method, arg].join(" ")
      elsif arg.class == Array
        arg = arg.flatten.select { |a| a.class == String || a.class == Symbol || a.respond_to?(:symbol) }
        arg = arg.map { |a| if a.respond_to?(:symbol) then a = a.symbol else a end }
        return arg.unshift(@method).join(" ")
      end
    end

  end

  class Summary
    attr_accessor :cache
    def namespace
      :summary
    end

    def method
      :summary_detail
    end

    def initialize
      @cache = Redis::Namespace.new(:summary, redis: REDIS)
      @method = "summary_detail"
    end

    def self.get(symbol)
      summary = YF::Summary.new
      summary.cache.get(symbol)
    end

    def self.set(symbol, data)
      summary = YF::Summary.new
      summary.cache.set(symbol, data)
    end
  end



  # Gets each stonk, reads the value from the cache, outputs as a JSON Array
  # This logic might be better implemented in the Controller
  def self.api_feed
    stonks = []
    get_stonks.each do |stonk|
      stonks << read_stonk_cache(stonk)
    end
    response = stonks
    return response
  end


  # Better implemented in Controller
  def self.get_stonks
    return Search.last.stonks.pluck(:symbol)
  end

  # Functionality re-created
  def self.read_stonk_cache(stonk)
    JSON.parse(REDIS.get(stonk))
  end

  ########

  # This belongs in an API class
  # It will know how to talk to the API, and how to format the arguments to be good for it.
  # Then the other classes can depend on its interface reliably.
  def self.get_stonk_data(arg)
    arg = clean_arguments(arg)
    output = `python lib/stonk_data.py #{arg}`
    return JSON.parse(output).to_json
  end

  # This should be in the Summary (and other) classes, but it needs API access to function
  def self.update_stonk_cache
    get_stonks.each do |stonk|
      data = get_stonk_data(stonk)
      REDIS.set(stonk, data)
    end
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
  register Sinatra::ActiveRecordExtension
  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  get '/api/stonks' do
    content_type 'application/json'
    return YF.api_feed.to_json
  end



  options "*" do
    response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
    response.headers["Access-Control-Allow-Origin"] = "*"
    200
  end

  options '/api/stonks' do

  end

end

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

    def request(args)
      args = prepare_arguments(args)
      response = `python lib/YF.py #{args}`
      return JSON.parse(response)
    end

    def prepare_arguments(arg)
      if symbolize(arg)
        arg = symbolize(arg)
        return arg.unshift(@method).join(" ")
      end
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

    def self.fetch(stonks)
      this = self.new
      response = []
      if symbolize(stonks)
        stonks = symbolize(stonks)
        stonks.each do |stonk|
          data = {}
          data[stonk] = JSON.parse(this.cache.get(stonk))
          response << data
        end
      end
      return response
    end

    def self.update(stonks)
      this = self.new
      response = this.api.request(stonks)
      if response.count == 1
        this.cache.set(response.keys[0], response)
      elsif response.count > 1
        response.keys.map { |k| this.cache.set(k, response[k]) }
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

end



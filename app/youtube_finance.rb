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

  class Endpoint
    # This class cannot be instantiated on its own.
    # Inherit from it, defining a namespace, and a method function to utilize
    extend YF::Helpers
    attr_accessor :cache, :api
    def initialize
      @cache  = YF::Cache.new(namespace)
      @api    = YF::API.new(method)
    end
    def namespace
      # This is a symbol corresponding to the prefix used for the namespaced cache
    end
    def method
      # This is a symbol corresponding to the actual method call used by YahooQuery
    end

    def self.fetch(stonks)
      # Fetches the current data corresponding to each passed stonk from the API, and returns it
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
      # Makes an API Call for the passed stonks, and updates the cache data to correspond
      this = self.new
      response = this.api.request(stonks)
      if response.count == 1
        this.cache.set(response.keys[0], response)
      elsif response.count > 1
        response.keys.map { |k| this.cache.set(k, response[k]) }
      end
    end

    def self.collect(stonks, frequency: 1.minute, duration: 3.minutes,
                     output_dir: "YF_Analysis", filename: )
      # Initially, working with JSON, all that I need to do is to figure out the timestamps
      # Write a new JSON file, and then add a new key to it with that timestamp, and the result

      if stonks == :all
        stonks = Stonk.all
      end

      this = self.new

      # This controls the while loop, and also provides the seed for the output directory
      start_time = Time.now
      finish_time = start_time + duration
      next_time = start_time + frequency

      actual_dir = "#{output_dir}/#{this.method.to_s}"
      filename = "#{filename}.json"


      FileUtils.mkdir_p actual_dir

      total_response = {}

      while Time.now < finish_time
        this_time = Time.now
        next_time += frequency

        # It's making this call to get access to the API and the method
        response = this.api.request(stonks)

        this_response = {}
        response.keys.map { |k| this_response[k] = response[k] }
        total_response[this_time] = this_response

        sleep 0.1.seconds until Time.now >= next_time
      end

      file = File.open("#{actual_dir}/#{filename}", "w+")
      file.write(JSON.dump(total_response))
      file.close
    end

  end


  class Summary < YF::Endpoint
    def namespace
      :summary
    end
    def method
      :summary_detail
    end
  end

  class Quotes < YF::Endpoint
    def namespace
      :quote
    end
    def method
      :quotes
    end
  end

end



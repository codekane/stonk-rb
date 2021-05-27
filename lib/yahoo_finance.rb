module YF
  module Helpers
    def symbolize(arg)
      if arg == :all
        arg = Stonks.all
      elsif arg.class == String || arg.class == Symbol || arg.respond_to?(:symbol)
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



  # Returns data in a way that is suited for the API response
  class Response
    extend YF::Helpers
    def self.fetch(symbols)
      response = {}
      if symbolize(symbols)
        symbols = symbolize(symbols)

        symbols.each do |symbol|
          cache = YF::Cache.new(symbol)
          if !cache.keys.empty?
            data = {}
            cache.keys.each do |key|
              data[key] = JSON.parse(cache.get(key))
            end
            response[symbol.to_s] = data
          end
        end
      end
      return response
    end

  end




  module Automation
    def self.update_data
      Search.connection
      stonks = Search.last.stonks

      YF::Quotes.update(stonks)
      YF::Summary.update(stonks)
      # The return value on this sucks, but at least the logic is outside of the Rakefile
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

    def get(key)
      @redis.get(key)
    end

    def set(key, data)
      @redis.set(key, JSON.dump(data))
    end

    def keys
      @redis.keys
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
          if (this.cache.get(stonk))
            data[stonk] = JSON.parse(this.cache.get(stonk))
            response << data
          end
        end
      end
      return response
    end

    def self.update(stonks)
      # TODO: Remove once dependancy has been removed.
      this = self.new
      response = this.api.request(stonks)
      if response.count == 1
        this.cache.set(response.keys[0], response)
      elsif response.count > 1
        response.keys.map { |k| this.cache.set(k, response[k]) }
      end
      # New COde
      # This creates a new cache, using the stonk as the namespace (instead of the method)
      # It then creates a key for every value in the response.
      # This will operate in parallel with the present functionality (above)
      # This can be tested by seeing if I can access data in the cache using the stonk prefix
      response.keys.each do |stonk|
        cache = Cache.new(stonk)
        for key in response[stonk].keys
          cache.set(key, response[stonk][key])
        end
      end
      # The above bit works, just FYI...
    end

    # This, and the analyze function should both be in their own class...
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

      # Dependence on this.method. Method should be passed in as an argument
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

    def self.analyze(file, dir: "YF_Analysis")
      this = self.new
      if File.file?("#{dir}/#{this.method}/#{file}.json")
        # Open the file. Convert it into a hash.
        collected_file = File.open("#{dir}/#{this.method}/#{file}.json")
        file_data = JSON.parse(File.read(collected_file))
        # Now I have a parsed hash. It is keyed to dates.
        output_data = {}

        timestamps = file_data.keys
        # Each date is followed by a number of keys for stocks
        stocks = file_data[timestamps.first].keys
        stocks.each do |stock|
          stock_data = {}
          one_minute_ago = nil
          timestamps.each do |timekey|
            if one_minute_ago == nil
              stock_data[timekey] = file_data[timekey][stock].keys
              one_minute_ago = file_data[timekey][stock].keys
            else
              next if file_data[timekey][stock].keys == one_minute_ago
              stock_data[timekey] = file_data[timekey][stock].keys
            end
          end
          output_data[stock] = stock_data
        end
        output_file = File.open("#{dir}/#{this.method}/#{file}_analyzed.json", "w+")
        output_file.write(JSON.dump(output_data))
        output_file.close
        puts "File not found. Did you mean one of these?"
        available_files = Dir.glob("#{dir}/#{this.method}/*.json")
        puts available_files
      end

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


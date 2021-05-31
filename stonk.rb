require './config/environment.rb'
require 'pry'



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
    search = Search.last
    @stonks = search.stonks

    response = YF::Response.fetch(@stonks)
    @stonks.each do |stonk|
      if response[stonk.symbol]
        response[stonk.symbol]["count"] = stonk.count(search.id)
      end
    end

    return response.to_json
  end

  get '/api/quotes' do
    content_type 'application/json'
    response.headers['Access-Control-Allow-Origin'] = '*'
    @stonks = Search.last.stonks
    return YF::Quotes.fetch(@stonks).to_json

  end


  options "*" do
    response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
    response.headers["Access-Control-Allow-Origin"] = "*"
    200
  end


end

require 'rack/test'

describe APIController do
  include Rack::Test::Methods

  def app
    APIController.new
  end

  # context :api do
  #   context :stonks do
  #     it 'returns status code 200' do
  #       get '/api/stonks'

  #       expect(last_response.status).to be(200)
  #     end
  #     it 'returns JSON' do
  #       get '/api/stonks'

  #       expect(last_response.headers["Content-Type"]).to include("application/json")
  #     end

  #     it 'returns correctly' do
  #       99.times do |index|
  #         stonk = Stonk.new
  #         stonk.symbol = "test#{index}"
  #         stonk.save
  #       end

  #       get '/api/stonks'

  #       expect(JSON.parse(last_response.body).count).to be(99)
  #     end
  #   end
  # end

end

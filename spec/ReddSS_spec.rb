require 'reddss'
describe ReddSS do
  before(:each) do
    @test = ReddSS.new
  end
  describe ".rising" do
    it "returns a hash composed of integers keyed to stock symbols" do
      output = @test.rising
      key = output.keys[0]

      expect(output.class).to eq(Hash)
      expect(output[key].class).to eq(Integer)
      expect(key.class).to eq(Symbol)
    end
  end

end

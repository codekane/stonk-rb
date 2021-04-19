require 'reddit_search'

describe RedditSearch do
  before(:each) do
    @test = RedditSearch.new('wallstbets')
  end
  describe ".run_search" do
    it "returns a hash composed of integers keyed to stock symbols" do
      output = @test.run_search
      key = output.keys[0]

      expect(output.class).to eq(Hash)
      expect(output[key].class).to eq(Integer)
      expect(key.class).to eq(Symbol)
    end
  end
end

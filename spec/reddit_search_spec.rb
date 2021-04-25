require 'spec_helper'
require 'reddit_search'

#Skipped because this is long and ugly!
#describe RedditSearch do
#  before(:each) do
#    @test = RedditSearch.new('wallstbets')
#  end
#  describe ".run_search" do
#    it "returns a hash composed of integers keyed to stock symbols" do
#      output = @test.run_search
#      key = output.keys[0]
#
#      expect(output.class).to eq(Hash)
#      expect(output[key].class).to eq(Integer)
#      expect(key.class).to eq(Symbol)
#    end
#  end
#end

describe SearchHandler do
  before do
    @search1 = {:SMOON=>4, :GME=>24, :RGBP=>16, :BIDU=>8, :EYES=>8, :FBRX=>8, :ROOT=>8, :OTRK=>8, :HJLI=>8, :PUBM=>8, :ASO=>8, :GOGO=>8, :BLNK=>8}
    @search2 = {:SMOON=>4, :GME=>24, :RGBP=>16, :BIDU=>8, :EYES=>8, :FBRX=>8, :ROOT=>8, :OTRK=>8, :HJLI=>8, :PUBM=>8, :ASO=>8, :GOGO=>8, :BLNK=>8, :PENIS=>99}
  end

  describe ".populateStonks" do
    it "fills an empty DB table with all of the stonks that it found" do
      search = SearchHandler.new(@search1)

      expect(Stonk.count).to eq(0)
      search.populateStonks
      expect(Stonk.count).to eq(@search1.count)
    end

    it "won't add anything if all the symbols already exist" do
      search = SearchHandler.new(@search1)
      search.populateStonks

      var = Stonk.count
      search.populateStonks

      expect(Stonk.count).to eq(var)
    end

    it "is content to add just one new stock to the record" do
      search = SearchHandler.new(@search1)
      search.populateStonks

      var = Stonk.count
      search2 = SearchHandler.new(@search2)
      search2.populateStonks

      expect(Stonk.count).to eq(var + 1)

    end
  end

  describe ".populateSearch" do
    it "builds a fully formed object, I don't know what I'm neeeding to test here"
  end


end

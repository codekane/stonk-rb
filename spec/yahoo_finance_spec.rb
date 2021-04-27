#require 'spec_helper'

describe YF::API, ".prepare_arguments" do
  before(:each) do
    @api = YF::API.new("summary_detail")
  end
  it "should return a string of the correct format" do
    test = @api.prepare_arguments("GOOG")

    expect(test).to eq("summary_detail GOOG")
  end

  it "should accept a symbol and still return the correct string" do
    test = @api.prepare_arguments(:GOOG)

    expect(test).to eq("summary_detail GOOG")
  end

  it "should do nothing if I pass it a hash" do
    test = @api.prepare_arguments({"penis": "vagina"})

    expect(test).to be(nil)
  end

  it "should accept any Object that responds to symbol" do
    obj = Object.new
    obj.define_singleton_method(:symbol) do "Penis" end
    test = @api.prepare_arguments(obj)

    expect(test).to eq("summary_detail Penis")
  end

  it "should parse nested arays of strings and symbols" do
    arr = ["test", ["penis", :GOOG]]
    test = @api.prepare_arguments(arr)

    expect(test).to eq("summary_detail test penis GOOG")
  end

  it "should not parse hashes in an array" do
    arr = ["GOOG", :GME, {"penis": "vagina"}]
    test = @api.prepare_arguments(arr)

    expect(test).to eq("summary_detail GOOG GME")
  end

  it "should not parse hashes" do
    arr = ["Penis", :Goog, {"Penis": "Vagina"}]
    test = @api.prepare_arguments(arr)

    expect(test).to eq("summary_detail Penis Goog")
  end

  it "should be able to parse this monster" do
    obj = Object.new
    obj.define_singleton_method(:symbol) { "Penis" }
    arr = [:GOOG, :GOGO, :GME, "Penis", "Vagina", [{"penis": "vagina"}, {"penis": "vagina"}]]
    test = @api.prepare_arguments(arr)

    expect(test).to eq("summary_detail GOOG GOGO GME Penis Vagina")
  end
end

describe YF::API, '.request' do
  before(:each) do
    @api = YF::API.new("summary_detail")
  end

  it "returns parsed JSON" do
    test = @api.request(["GOOG", "GME"])
    expect(test.class).to be(Hash)
  end


  it "contains one element for every arguments passed in" do
    symbols =["GOOG", "GME", "TSLA", "RGBP", "BIDU", "EYES", "FBRX", "ROOT", "OTRK", "HJLI", "PUBM", "ASO", "GOGO", "BLNK", "SMOON"]
    test = @api.request(symbols)

    expect(test.count).to eq(symbols.count)
  end
end

describe YF::Cache do
  before(:each) do
    @cache = YF::Cache.new(:summary)
  end
  describe ".set" do
    it "should return OK" do
      test = @cache.set("PENIS", "VAGINA")
      expect(test).to eq("OK")
    end

    it "should prefix the save value with summary" do
      @cache.set("PENIS", "VAGINA")
      result = JSON.parse(REDIS.get("summary:PENIS"))
      expect(result).to eq("VAGINA")
    end

  end

  describe ".get" do
    it "should successfully return a value being set by the same class" do
      @cache.set("PENIS", "VAGINA")

      result = @cache.get("PENIS")
      expect(JSON.parse(result)).to eq("VAGINA")
    end

    it "should fail to return a value set with the base redis instance" do
      REDIS.set("PENIS", "VAGINA")
      expect(@cache.get("PENIS")).to be(nil)
    end

  end

end


describe YF::Summary do
  before do
    stonks = ["GME", "RGBP", "BIDU", "EYES", "FBRX", "ROOT", "OTRK", "HJLI", "PUBM", "ASO", "GOGO", "BLNK"]
    stonks.each do |stonk| Stonk.create(symbol: stonk).save end
    @stonks = Stonk.all
    @test = YF::Summary
  end

  describe "update" do
    it "is saving to Redis" do
      test = YF::Cache.new("summary")
      test.set("GME", "Penis")
      YF::Summary.update("GME")

      expect(YF::Summary.fetch("GME")).not_to eq("Penis")
    end


    describe ".fetch" do

    end

  end
end

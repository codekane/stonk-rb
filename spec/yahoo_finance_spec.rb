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

  it "responds to the key 'response' and returns an array" do
    test = @api.request(["GOOG", "GME"])

    expect(test["response"].class).to be(Array)
  end

  it "contains one element for every arguments passed in" do
    symbols =["GOOG", "GME", "TSLA", "RGBP", "BIDU", "EYES", "FBRX", "ROOT", "OTRK", "HJLI", "PUBM", "ASO", "GOGO", "BLNK", "SMOON"]
    test = @api.request(symbols)

    expect(test["response"].count).to eq(symbols.count)
  end
end

describe YF::Summary do
  describe ".set" do
    it "should return OK" do
      test = YF::Summary.set("PENIS", "VAGINA")
      expect(test).to eq("OK")
    end

    it "should prefix the save value with summary" do
      YF::Summary.set("PENIS", "VAGINA")
      expect(REDIS.get("summary:PENIS")).to eq("VAGINA")
    end
  end

  describe ".get" do
    it "should successfully return a value being set by the same class" do
      YF::Summary.set("PENIS", "VAGINA")
      expect(YF::Summary.get("PENIS")).to eq("VAGINA")
    end

    it "should fail to return a value set with the base redis instance" do
      REDIS.set("PENIS", "VAGINA")
      expect(YF::Summary.get("PENIS")).to be(nil)
    end

  end

  describe ".update" do
    it "updates the passed keys value with new results from the YF API"
  end

  describe ".update_all" do
    it "updates all keys with new results from the YF API"

  end
end

describe YF do


  describe ".clean_arguments" do
    it "passes a string through unchanged" do
      string = "this is a string"

      expect(YF.clean_arguments(string)).to eq(string)
    end

    it "takes an array of strings, and converts it into a single string" do
      array = ["this", "is", "an", "array"]
      expected = "this is an array"

      expect(YF.clean_arguments(array)).to eq(expected)
    end

    it "accepts a Stonk, and returns a string symbol value" do
      stonk = Stonk.new(symbol: "TEST")

      expect(YF.clean_arguments(stonk)).to eq(stonk.symbol)
    end

    it "accepts an array of many stonks, returning a single, correctly formatted string" do
      stonk1 = Stonk.new(symbol: "TEST")
      stonk2 = Stonk.new(symbol: "TSLA")
      stonk3 = Stonk.new(symbol: "GOOG")
      arr = [stonk1, stonk2, stonk3]
      expected = "TEST TSLA GOOG"

      expect(YF.clean_arguments(arr)).to eq(expected)


    end

    it "accepts an array of mixed strings and stonks" do
      stonk1 = Stonk.new(symbol: "TSLA")
      stonk2 = Stonk.new(symbol: "GOOG")
      stonk3 = "TEST"
      arr = [stonk1, stonk2, stonk3]
      expected = "#{stonk1.symbol} #{stonk2.symbol} #{stonk3}"

      expect(YF.clean_arguments(arr)).to eq(expected)

    end

  end

end

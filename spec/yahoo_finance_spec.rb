require '../stonk.rb'

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

require 'spec_helper'
require 'pry'

describe "YahooQuery interface" do
  context "::summary_detail" do
    before do
      @method = 'summary_detail'
      @valid = ["GME", "GOOG", "TSLA"]
      @invalid = ["Penis", "Vagina", "Asshole"]
    end

    it "doesn't return nothing" do
      response = `python lib/YF.py #{@method} #{@valid[0]}`
      expect(response).not_to eq("")
    end

    it "returns a JSON parseable string keyed to 'response'" do
      response = `python lib/YF.py #{@method} #{@valid[0]}`
      expect(JSON.parse(response).keys).to eq(["response"])
    end

    it "handles multiple arguments" do
      arr = @valid.join(" ")
      response = `python lib/YF.py #{@method} #{arr}`

      expect(JSON.parse(response)["response"].count).to eq(3)
    end
  end
  context "::quotes" do
    before do
      @method = 'quotes'
      @valid = ["GME", "GOOG", "TSLA"]
      @invalid = ["Penis", "Vagina", "Asshole"]
    end
    it "doesn't return nothing" do
      response = `python lib/YF.py #{@method} #{@valid[0]}`
      expect(response).not_to eq("")
    end
    it "returns a JSON parseable string keyed to 'response'" do
      response = `python lib/YF.py #{@method} #{@valid[0]}`
      expect(JSON.parse(response).keys).to eq(["response"])
    end

    it "handles multiple arguments" do
      arr = @valid.join(" ")
      response = `python lib/YF.py #{@method} #{arr}`

      expect(JSON.parse(response)["response"].count).to eq(3)
    end



  end

  #context "quotes method" do

  #  it "handles the quotes method" do
  #    method = 'quotes'
  #    stock = 'GOOG'

  #    response = `python lib/YF.py #{method} #{stock}`
  #    expect(response).not_to eq("")

  #  end
  #end

end

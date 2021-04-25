require 'spec_helper'
# {:SMOON=>4, :GME=>24, :RGBP=>16, :BIDU=>8, :EYES=>8, :FBRX=>8, :ROOT=>8,
# :OTRK=>8, :HJLI=>8, :PUBM=>8, :ASO=>8, :GOGO=>8, :BLNK=>8}

describe Stonk do
  describe "validations" do
    it "should be unique" do
      stonk1 = Stonk.new(symbol: "TEST")
      stonk2 = Stonk.new(symbol: "TEST")

      expect(stonk1.valid?).to be true
      stonk1.save

      expect(stonk2.valid?).to be false
    end
  end
end

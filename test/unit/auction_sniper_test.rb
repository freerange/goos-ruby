require "test_helper"

require "auction_sniper"

describe AuctionSniper do
  before do
    @sniper_listener = mock("SniperListener")
    @sniper = AuctionSniper.new(@sniper_listener)
  end

  it "reports lost when auction closes" do
    @sniper_listener.expects(:sniper_lost)
    @sniper.auction_closed
  end
end

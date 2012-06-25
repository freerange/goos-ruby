require "test_helper"

require "auction_sniper"

describe AuctionSniper do
  before do
    @auction = mock("Auction")
    @sniper_listener = mock("SniperListener")
    @sniper = AuctionSniper.new(@auction, @sniper_listener)
  end

  it "reports lost when auction closes" do
    @sniper_listener.expects(:sniper_lost).at_least_once
    @sniper.auction_closed
  end

  it "bids higher and reports bidding when new price arrives" do
    price = 1001
    increment = 25
    @auction.expects(:bid).with(price + increment)
    @sniper_listener.expects(:sniper_bidding).at_least_once
    @sniper.current_price(price, increment)
  end
end

require "test_helper"

require "auction_sniper"
require "end-to-end/fake_auction_server"
require "end-to-end/application_runner"

describe AuctionSniper do
  before do
    @auction = FakeAuctionServer.new("item-54321")
    @application = ApplicationRunner.new
  end

  after do
    @auction.stop
    @application.stop
  end

  it "joins auction until auction closes" do
    @auction.start_selling_item
    @application.start_bidding_in(@auction)
    @auction.has_received_join_request_from_sniper
    @auction.announce_closed
    @application.shows_sniper_has_lost_auction
  end
end

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
    @auction.has_received_join_request_from(ApplicationRunner::SNIPER_XMPP_ID)
    @auction.announce_closed
    @application.shows_sniper_has_lost_auction
  end

  it "makes a higher bid but loses" do
    @auction.start_selling_item
    @application.start_bidding_in(@auction)
    @auction.has_received_join_request_from(ApplicationRunner::SNIPER_XMPP_ID)
    @auction.report_price(1000, 98, "other bidder")
    @application.has_shown_sniper_is_bidding
    @auction.has_received_bid(1098, ApplicationRunner::SNIPER_XMPP_ID)
    @auction.announce_closed
    @application.shows_sniper_has_lost_auction
  end

  it "wins an auction by bidding higher" do
    @auction.start_selling_item
    @application.start_bidding_in(@auction)
    @auction.has_received_join_request_from(ApplicationRunner::SNIPER_XMPP_ID)
    @auction.report_price(1000, 98, "other bidder")
    @application.has_shown_sniper_is_bidding
    @auction.has_received_bid(1098, ApplicationRunner::SNIPER_XMPP_ID)
    @auction.report_price(1098, 97, ApplicationRunner::SNIPER_XMPP_ID)
    @application.has_shown_sniper_is_winning
    @auction.announce_closed
    @application.shows_sniper_has_won_auction
  end
end

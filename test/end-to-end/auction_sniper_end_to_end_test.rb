require "test_helper"

require "auction_sniper"
require "end-to-end/fake_auction_server"
require "end-to-end/application_runner"

describe AuctionSniper do
  before do
    @auction = FakeAuctionServer.new("item-54321")
    @auction2 = FakeAuctionServer.new("item-65432")
    @application = ApplicationRunner.new
  end

  after do
    @auction.stop
    @auction2.stop
    @application.stop
  end

  it "joins auction until auction closes" do
    @auction.start_selling_item
    @application.start_bidding_in(@auction)
    @auction.has_received_join_request_from(ApplicationRunner::SNIPER_XMPP_ID);
    @auction.announce_closed
    @application.shows_sniper_has_lost_auction(@auction, 0, 0)
  end

  it "makes a higher bid but loses" do
    @auction.start_selling_item
    @application.start_bidding_in(@auction)
    @auction.has_received_join_request_from(ApplicationRunner::SNIPER_XMPP_ID);
    @auction.report_price(1000, 98, "other bidder")
    @application.has_shown_sniper_is_bidding(@auction, 1000, 1098)
    @auction.has_received_bid(1098, ApplicationRunner::SNIPER_XMPP_ID)
    @auction.announce_closed
    @application.shows_sniper_has_lost_auction(@auction, 1000, 1098)
  end

  it "wins an auction by bidding higher" do
    @auction.start_selling_item
    @application.start_bidding_in(@auction)
    @auction.has_received_join_request_from(ApplicationRunner::SNIPER_XMPP_ID)
    @auction.report_price(1000, 98, "other bidder")
    @application.has_shown_sniper_is_bidding(@auction, 1000, 1098)
    @auction.has_received_bid(1098, ApplicationRunner::SNIPER_XMPP_ID)
    @auction.report_price(1098, 97, ApplicationRunner::SNIPER_XMPP_ID)
    @application.has_shown_sniper_is_winning(@auction, 1098)
    @auction.announce_closed
    @application.shows_sniper_has_won_auction(@auction, 1098)
  end

  it "bids for multiple items" do
    @auction.start_selling_item
    @auction2.start_selling_item
    @application.start_bidding_in(@auction, @auction2)
    @auction.has_received_join_request_from(ApplicationRunner::SNIPER_XMPP_ID)
    @auction2.has_received_join_request_from(ApplicationRunner::SNIPER_XMPP_ID)
    @auction.report_price(1000, 98, "other bidder")
    @auction.has_received_bid(1098, ApplicationRunner::SNIPER_XMPP_ID)
    @auction2.report_price(500, 21, "other bidder")
    @auction2.has_received_bid(521, ApplicationRunner::SNIPER_XMPP_ID)
    @auction.report_price(1098, 97, ApplicationRunner::SNIPER_XMPP_ID)
    @auction2.report_price(521, 22, ApplicationRunner::SNIPER_XMPP_ID)
    @application.has_shown_sniper_is_winning(@auction, 1098)
    @application.has_shown_sniper_is_winning(@auction2, 521)
    @auction.announce_closed
    @auction2.announce_closed
    @application.shows_sniper_has_won_auction(@auction, 1098)
    @application.shows_sniper_has_won_auction(@auction2, 521)
  end

  it "loses an auction when the price is too high" do
    @auction.start_selling_item
    @application.start_bidding_with_stop_price(@auction, 1100)
    @auction.has_received_join_request_from(ApplicationRunner::SNIPER_XMPP_ID)
    @auction.report_price(1000, 98, "other bidder")
    @application.has_shown_sniper_is_bidding(@auction, 1000, 1098)
    @auction.has_received_bid(1098, ApplicationRunner::SNIPER_XMPP_ID)
    @auction.report_price(1197, 10, "third party")
    @application.has_shown_sniper_is_losing(@auction, 1197, 1098)
    @auction.report_price(1207, 10, "fourth party")
    @application.has_shown_sniper_is_losing(@auction, 1207, 1098)
    @auction.announce_closed
    @application.shows_sniper_has_lost_auction(@auction, 1207, 1098)
  end

  it "sniper_reports_invalid_auction_message_and_stops_responding_to_events" do
    broken_message = "a broken message"
    @auction.start_selling_item
    @auction2.start_selling_item
    @application.start_bidding_in(@auction, @auction2)
    @auction.has_received_join_request_from(ApplicationRunner::SNIPER_XMPP_ID)
    @auction.report_price(500, 20, "other bidder")
    @auction.has_received_bid(520, ApplicationRunner::SNIPER_XMPP_ID)
    @auction.send_invalid_message_containing(broken_message)
    @application.shows_sniper_has_failed(@auction)
    @auction.report_price(520, 21, "other bidder")
    wait_for_another_auction_event
    @application.reports_invalid_message(@auction, broken_message)
    @application.shows_sniper_has_failed(@auction)
  end

  private

  def wait_for_another_auction_event
    @auction2.has_received_join_request_from(ApplicationRunner::SNIPER_XMPP_ID)
    @auction2.report_price(600, 6, "other bidder")
    @application.has_shown_sniper_is_bidding(@auction2, 600, 606)
  end
end
